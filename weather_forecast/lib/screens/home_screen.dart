import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cityController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await Provider.of<WeatherProvider>(context, listen: false).fetchByLocation();
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to load weather data. Check your connection or try again.';
        });
      }
    });
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  String getThunderstormProbability(int? conditionCode) {
    if (conditionCode == null) return '0%';
    if (conditionCode >= 200 && conditionCode <= 232) {
      return 'High';
    } else if (conditionCode >= 300 && conditionCode <= 321) {
      return 'Moderate';
    } else {
      return 'Low';
    }
  }

  // Dynamic color based on weather condition
  Color getWeatherColor(String? description) {
    if (description == null) return Colors.blue.shade900;
    description = description.toLowerCase();
    if (description.contains('clear') || description.contains('sunny')) {
      return Colors.orange.shade700;
    } else if (description.contains('rain') || description.contains('shower')) {
      return Colors.blue.shade700;
    } else if (description.contains('cloud')) {
      return Colors.grey.shade600;
    } else if (description.contains('thunder')) {
      return Colors.purple.shade700;
    }
    return Colors.blue.shade900;
  }

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WeatherProvider>(context);
    final primaryColor = getWeatherColor(wp.current?.weatherDescription);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Forecast',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              setState(() {
                errorMessage = null;
              });
              try {
                await Provider.of<WeatherProvider>(context, listen: false).fetchByLocation();
              } catch (e) {
                setState(() {
                  errorMessage = 'Failed to refresh weather data. Try again.';
                });
              }
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.8),
              Colors.cyan.shade200,
              Colors.purple.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: wp.loading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 6,
                ),
                const SizedBox(height: 16),
                Text(
                  'Fetching Weather...',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : wp.current == null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? 'No weather data available.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      errorMessage = null;
                    });
                    try {
                      await Provider.of<WeatherProvider>(context, listen: false)
                          .fetchByLocation();
                    } catch (e) {
                      setState(() {
                        errorMessage = 'Failed to load weather data. Try again.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: cityController,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        hintStyle: TextStyle(
                          fontFamily: 'Roboto',
                          color: Colors.white70,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          try {
                            await wp.fetchByCity(value);
                            setState(() {
                              errorMessage = null;
                            });
                          } catch (e) {
                            setState(() {
                              errorMessage = 'Invalid city name or network error.';
                            });
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Current Weather Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          wp.current!.areaName ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        wp.current!.weatherIcon != null
                            ? Image.network(
                          'https://openweathermap.org/img/wn/${wp.current!.weatherIcon}@4x.png',
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.cloud_off, size: 120, color: Colors.white70),
                        )
                            : Icon(Icons.cloud_off, size: 120, color: Colors.white70),
                        const SizedBox(height: 12),
                        Text(
                          '${wp.current!.temperature?.celsius?.toStringAsFixed(1) ?? '--'} °C',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          wp.current!.weatherDescription?.toUpperCase() ?? 'N/A',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Additional Weather Details
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _WeatherDetail(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: '${wp.current!.humidity?.toStringAsFixed(0) ?? '--'}%',
                              tooltip: 'Percentage of moisture in the air',
                              color: primaryColor,
                            ),
                            _WeatherDetail(
                              icon: Icons.air,
                              label: 'Wind',
                              value: '${wp.current!.windSpeed?.toStringAsFixed(1) ?? '--'} m/s',
                              tooltip: 'Wind speed in meters per second',
                              color: primaryColor,
                            ),
                            _WeatherDetail(
                              icon: Icons.bolt,
                              label: 'Thunderstorm',
                              value: getThunderstormProbability(wp.current!.weatherConditionCode),
                              tooltip: 'Likelihood of thunderstorm activity',
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Forecast Title
                  Text(
                    '7-Day Forecast',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Forecast List
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4, // Limit height to prevent overflow
                    child: ListView.builder(
                      itemCount: wp.forecast?.length ?? 0,
                      itemBuilder: (context, index) {
                        final weather = wp.forecast![index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: index % 2 == 0
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.3),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: weather.weatherIcon != null
                                ? Image.network(
                              'https://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png',
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.cloud_off, size: 50, color: Colors.white70),
                            )
                                : Icon(Icons.cloud_off, size: 50, color: Colors.white70),
                            title: Text(
                              DateFormat('EEEE, MMM d').format(weather.date!.toLocal()),
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${weather.temperature?.celsius?.toStringAsFixed(1) ?? '--'} °C • ${weather.weatherDescription?.toUpperCase() ?? 'N/A'}',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Humidity: ${weather.humidity?.toStringAsFixed(0) ?? '--'}% • Wind: ${weather.windSpeed?.toStringAsFixed(1) ?? '--'} m/s',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for displaying weather details like humidity, wind, etc.
class _WeatherDetail extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String tooltip;
  final Color color;

  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.tooltip,
    required this.color,
  });

  @override
  _WeatherDetailState createState() => _WeatherDetailState();
}

class _WeatherDetailState extends State<_WeatherDetail> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                widget.value,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 10,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}