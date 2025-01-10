import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/service/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';


class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weatherData;

  WeatherModel? get weatherData => _weatherData;

  Future<void> fetchWeather(double lat, double lon) async {
    _weatherData = await _weatherService.fetchWeather(lat, lon);
    notifyListeners();
  }
}

// Determine Location
Future<Position> determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }


  LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  return await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );
}

