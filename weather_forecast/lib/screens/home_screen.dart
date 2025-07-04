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

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WeatherProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.cyan.shade300,
              Colors.purple.shade200,
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
                    foregroundColor: Colors.blue.shade900,
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
              : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: cityController,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.blue.shade900,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.blue.shade400,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.blue.shade900),
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
                const SizedBox(height: 24),
                // Current Weather Card
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          wp.current!.areaName ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        wp.current!.weatherIcon != null
                            ? Image.network(
                          'https://openweathermap.org/img/wn/${wp.current!.weatherIcon}@2x.png',
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.cloud_off, size: 100, color: Colors.grey.shade400),
                        )
                            : Icon(Icons.cloud_off, size: 100, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          '${wp.current!.temperature?.celsius?.toStringAsFixed(1) ?? '--'} °C',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          wp.current!.weatherDescription?.toUpperCase() ?? 'N/A',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Additional Weather Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _WeatherDetail(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: '${wp.current!.humidity?.toStringAsFixed(0) ?? '--'}%',
                              tooltip: 'Percentage of moisture in the air',
                            ),
                            _WeatherDetail(
                              icon: Icons.air,
                              label: 'Wind',
                              value: '${wp.current!.windSpeed?.toStringAsFixed(1) ?? '--'} m/s',
                              tooltip: 'Wind speed in meters per second',
                            ),
                            _WeatherDetail(
                              icon: Icons.bolt,
                              label: 'Thunderstorm',
                              value: getThunderstormProbability(wp.current!.weatherConditionCode),
                              tooltip: 'Likelihood of thunderstorm activity',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 16),
                // Forecast List
                Expanded(
                  child: ListView.builder(
                    itemCount: wp.forecast?.length ?? 0,
                    itemBuilder: (context, index) {
                      final weather = wp.forecast![index];
                      return Card(
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: weather.weatherIcon != null
                              ? Image.network(
                            'https://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png',
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.cloud_off, size: 60, color: Colors.grey.shade400),
                          )
                              : Icon(Icons.cloud_off, size: 60, color: Colors.grey.shade400),
                          title: Text(
                            DateFormat('EEEE, MMM d').format(weather.date!.toLocal()),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
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
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Humidity: ${weather.humidity?.toStringAsFixed(0) ?? '--'}% • Wind: ${weather.windSpeed?.toStringAsFixed(1) ?? '--'} m/s',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: Colors.blue.shade600,
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
    );
  }
}

// Widget for displaying weather details like humidity, wind, etc.
class _WeatherDetail extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String tooltip;

  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.tooltip,
  });

  @override
  _WeatherDetailState createState() => _WeatherDetailState();
}

class _WeatherDetailState extends State<_WeatherDetail> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                color: Colors.blue.shade800,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 10,
                  color: Colors.blue.shade700,
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