import 'package:weather/weather.dart';

class WeatherService {
  final WeatherFactory wf = WeatherFactory('a9239b3d6d8d90925da4d5c088a6fee9');

  Future<Weather> getCurrentWeather(double lat, double lon) =>
      wf.currentWeatherByLocation(lat, lon);

  Future<Weather> getCurrentWeatherByCity(String city) =>
      wf.currentWeatherByCityName(city);

  Future<List<Weather>> getForecast(double lat, double lon) async {
    final data = await wf.fiveDayForecastByLocation(lat, lon);
    final Map<String, Weather> uniqueDays = {};
    for (var w in data) {
      final date = w.date!.toLocal().toIso8601String().split("T")[0];
      uniqueDays.putIfAbsent(date, () => w);
    }
    return uniqueDays.values.toList();
  }
}