// models/sensor_data.dart
class SensorData {
  final double soilMoisture1;
  final double soilMoisture2;
  final double temperature;
  final double humidity;
  final bool rainDetected;
  final double flowRate;
  final bool tankLevel;
  final bool pumpOn;
  final double tds;

  SensorData({
    required this.soilMoisture1,
    required this.soilMoisture2,
    required this.temperature,
    required this.humidity,
    required this.rainDetected,
    required this.flowRate,
    required this.tankLevel,
    required this.pumpOn,
    required this.tds,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      soilMoisture1: (json['soilMoisture1'] ?? 0).toDouble(),
      soilMoisture2: (json['soilMoisture2'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      rainDetected: json['rainDetected'] ?? false,
      flowRate: (json['flowRate'] ?? 0).toDouble(),
      tankLevel: (json['tankLevel'] == 1),
      pumpOn: (json['pumpOn'] == 1),
      tds: (json['tds'] ?? 0).toDouble(),
    );
  }
}
