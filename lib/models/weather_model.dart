class WeatherModel {
  final double temperature;
  final String description;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['main']['temp'],
      description: json['weather'][0]['description'],
      cityName: json['name'],
    );
  }
}
