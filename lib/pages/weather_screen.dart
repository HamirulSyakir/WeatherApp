import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/provider/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  late Future<void> _weatherFuture;
  late AnimationController _rainController;
  late Animation<double> _rainAnimation;

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
    "Your Location": "assets/ampang.jpg",
  };

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _rainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_rainController);

    _weatherFuture = _loadWeather(favoriteIslands[0]['latitude'], favoriteIslands[0]['longitude']);
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
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

  Widget _buildWeatherIcon(String? description) {
    if (description == null) {
      return _buildAnimatedCloud();
    } else if (description.contains("cloud")) {
      return _buildAnimatedCloud();
    } else if (description.contains("rain")) {
      return _buildRealisticRain();
    } else if (description.contains("clear")) {
      return _buildSunnyIcon();
    } else {
      return _buildAnimatedCloud();
    }
  }

  Widget _buildAnimatedCloud() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.cloud,
          size: 120,
          color: Colors.white.withValues(alpha: 0.8), // Use double value
        ),
        Positioned(
          top: 20,
          child: Icon(
            Icons.cloud,
            size: 100,
            color: Colors.white.withValues(alpha: 0.6), // Use double value
          ),
        ),
        Positioned(
          left: 30,
          child: Icon(
            Icons.cloud,
            size: 80,
            color: Colors.white.withValues(alpha: 0.4), // Use double value
          ),
        ),
      ],
    );
  }

  Widget _buildRealisticRain() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.cloud,
          size: 120,
          color: Colors.white.withValues(alpha: 0.8), // Use double value
        ),
        AnimatedBuilder(
          animation: _rainAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(200, 200),
              painter: RainPainter(_rainAnimation.value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSunnyIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.wb_sunny,
          size: 120,
          color: Colors.yellow.withValues(alpha: 0.8), // Use double value
        ),
        Positioned(
          top: -20,
          child: Icon(
            Icons.wb_sunny,
            size: 100,
            color: Colors.yellow.withValues(alpha: 0.6), // Use double value
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
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
            // Island selection chips
            Container(
              height: 100.0,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: favoriteIslands.map((island) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ActionChip(
                        label: Text(
                          island['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: const Color(0xFF004A96),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
            // Weather display
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
                                _buildWeatherIcon(provider.weatherData?.description),
                                const SizedBox(height: 16),
                                Text(
                                  selectedIslandName,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${provider.weatherData?.temperature}°C',
                                  style: const TextStyle(
                                    fontSize: 64,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  provider.weatherData?.description ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _loadCurrentLocationWeather,
                                  icon: const Icon(
                                    Icons.location_on,
                                    size: 24,
                                  ),
                                  label: const Text(
                                    'Get My Location Weather',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                                    backgroundColor: const Color(0xFF004A96),
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

class RainPainter extends CustomPainter {
  final double progress;

  RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 20; i++) {
      final x = size.width * (i / 20);
      final y = (size.height * progress + i * 20) % size.height;
      canvas.drawLine(Offset(x, y), Offset(x, y + 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
