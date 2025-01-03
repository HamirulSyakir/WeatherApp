import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<void> _weatherFuture;
  String selectedIslandName = "Sipadan Island";  // Default island name

  // List of favorite scuba diving islands with their coordinates
  final List<Map<String, dynamic>> favoriteIslands = [
    {
      "name": "Sipadan Island",
      "latitude": 4.1150,
      "longitude": 118.6287,
    },
    {
      "name": "Perhentian Islands",
      "latitude": 5.9800,
      "longitude": 102.7444,
    },
    {
      "name": "Redang Island",
      "latitude": 5.8833,
      "longitude": 102.2167,
    },
    {
      "name": "Tioman Island",
      "latitude": 2.8150,
      "longitude": 104.1500,
    },
    {
      "name": "Lang Tengah Island",
      "latitude": 5.7333,
      "longitude": 103.0500,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load weather for the first island by default
    _weatherFuture = _loadWeather(favoriteIslands[0]['latitude'], favoriteIslands[0]['longitude']);
  }

  Future<void> _loadWeather(double latitude, double longitude) async {
    try {
      await Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeather(latitude, longitude);
    } catch (e) {
      throw Exception('Failed to load weather: $e');
    }
  }

  Future<void> _loadCurrentLocationWeather() async {
    try {
      // Call the determinePosition function to get the current location
      Position position = await determinePosition();
      _weatherFuture = _loadWeather(position.latitude, position.longitude);
      setState(() {
        selectedIslandName = "Your Location";  // Set name as "Your Location"
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Column(
        children: [
          // Text bar showing favorite scuba diving islands with a dark blue background
          Container(
            padding: EdgeInsets.all(8.0), // Dark blue background
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: favoriteIslands.map((island) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),  // Increase horizontal padding
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Update weather for the selected island
                          selectedIslandName = island['name'];  // Set selected island name
                          _weatherFuture = _loadWeather(island['latitude'], island['longitude']);
                        });
                      },
                      child: Chip(
                        label: Text(
                          island['name'],
                          style: TextStyle(
                            color: Colors.white,  // White text
                            fontSize: 18,  // Increase font size
                          ),
                        ),
                        backgroundColor: Color(0xFF00008B),  // Blue chip background
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),  // Increase padding
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _weatherFuture = _loadWeather(favoriteIslands[0]['latitude'], favoriteIslands[0]['longitude']);
                            });
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      if (provider.weatherData == null) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                selectedIslandName,  // Use the selected island name
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${provider.weatherData!['main']['temp']}°C',
                                style: TextStyle(fontSize: 64),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${provider.weatherData!['weather'][0]['description']}',
                                style: TextStyle(fontSize: 20),
                              ),
                              // Button to fetch current location weather placed below the description
                              ElevatedButton(
                                onPressed: _loadCurrentLocationWeather,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Color(0xFF00008B),     // Set text color to white
                                ),
                                child: Text('Get My Location Weather'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
