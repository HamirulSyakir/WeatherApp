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
  String selectedIslandName = "Sipadan Island"; // Default island name

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

  // Map of island names to background images
  final Map<String, String> backgroundImages = {
    "Sipadan Island": "assets/sipadan.jpg",
    "Perhentian Islands": "assets/perhentian.jpg",
    "Redang Island": "assets/redang.jpg",
    "Tioman Island": "assets/tioman.jpg",
    "Lang Tengah Island": "assets/lang_tengah.jpg",
    "Your Location": "assets/default.jpg",
  };

  @override
  void initState() {
    super.initState();
    _weatherFuture = _loadWeather(favoriteIslands[0]['latitude'], favoriteIslands[0]['longitude']);
  }

  Future<void> _loadWeather(double latitude, double longitude) async {
    try {
      await Provider.of<WeatherProvider>(context, listen: false).fetchWeather(latitude, longitude);
    } catch (e) {
      throw Exception('Failed to load weather: $e');
    }
  }

  Future<void> _loadCurrentLocationWeather() async {
    try {
      Position position = await determinePosition();
      _weatherFuture = _loadWeather(position.latitude, position.longitude);
      setState(() {
        selectedIslandName = "Your Location";
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
        title: const Text('Weather App'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImages[selectedIslandName] ?? "assets/default.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: favoriteIslands.map((island) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ActionChip(
                        label: Text(
                          island['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color(0xFF004A96),
                        onPressed: () {
                          setState(() {
                            selectedIslandName = island['name'];
                            _weatherFuture = _loadWeather(island['latitude'], island['longitude']);
                          });
                        },
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _weatherFuture = _loadWeather(favoriteIslands[0]['latitude'], favoriteIslands[0]['longitude']);
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Consumer<WeatherProvider>(
                      builder: (context, provider, child) {
                        if (provider.weatherData == null) {
                          return const Center(child: CircularProgressIndicator());
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedIslandName,
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${provider.weatherData!['main']['temp']}°C',
                                  style: const TextStyle(fontSize: 64),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${provider.weatherData!['weather'][0]['description']}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadCurrentLocationWeather,
                                  icon: const Icon(Icons.location_on),
                                  label: const Text('Get My Location Weather'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF004A96),
                                    foregroundColor: Colors.white,
                                  ),
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
      ),
    );
  }
}
