import 'package:flutter/material.dart';
import 'package:weather_app/pages/weather_screen.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:provider/provider.dart';


// Main App
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: WeatherScreen(),
      ),
    ),
  );
}
