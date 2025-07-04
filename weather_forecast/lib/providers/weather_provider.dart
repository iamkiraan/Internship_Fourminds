import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:weather/weather.dart';
import '../services/location_service.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? current;
  List<Weather>? forecast;
  bool loading = false;

  final WeatherService service = WeatherService();

  Future<void> fetchByLocation() async {
    loading = true;
    notifyListeners();
    final pos = await LocationService.determinePosition();
    current = await service.getCurrentWeather(pos.latitude, pos.longitude);
    forecast = await service.getForecast(pos.latitude, pos.longitude);
    loading = false;
    notifyListeners();
  }

  Future<void> fetchByCity(String city) async {
    loading = true;
    notifyListeners();
    current = await service.getCurrentWeatherByCity(city);
    forecast = await service.getForecast(current!.latitude!, current!.longitude!);
    loading = false;
    notifyListeners();
  }
}