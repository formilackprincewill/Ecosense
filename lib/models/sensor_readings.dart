// lib/models/sensor_readings.dart

class SensorReadings {
  // Ambient Light Sensor (lux)
  final int? lightIntensity;
  // Microphone (Noise Level in dB)
  final double? noiseLevel;
  // Barometer (Pressure in hPa, Temperature in °C if available)
  final double? pressure;
  final double? temperature;
  // Accelerometer (m/s^2)
  final double? accX, accY, accZ;
  // Gyroscope (rad/s)
  final double? gyroX, gyroY, gyroZ;
  // GPS Location
  final double latitude;
  final double longitude;
  final double? altitude; // meters
  // Timestamp of the reading or submission
  final DateTime timestamp;

  SensorReadings({
    this.lightIntensity,
    this.noiseLevel,
    this.pressure,
    this.temperature,
    this.accX,
    this.accY,
    this.accZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.timestamp,
  });

  // Initial state with default location (0,0) and current time
  static SensorReadings initial() =>
      SensorReadings(lightIntensity: 0, latitude: 0.0, longitude: 0.0, timestamp: DateTime.now());

  // JSON Deserialization Layer added to safely ingest database rows
  factory SensorReadings.fromJson(Map<String, dynamic> json) {
    return SensorReadings(
      lightIntensity: json['light_intensity'] ?? json['lightIntensity'],
      noiseLevel: (json['noise_level'] ?? json['noiseLevel'])?.toDouble(),
      pressure: (json['pressure'])?.toDouble(),
      temperature: (json['temperature'])?.toDouble(),
      accX: (json['acc_x'] ?? json['accX'])?.toDouble(),
      accY: (json['acc_y'] ?? json['accY'])?.toDouble(),
      accZ: (json['acc_z'] ?? json['accZ'])?.toDouble(),
      gyroX: (json['gyro_x'] ?? json['gyroX'])?.toDouble(),
      gyroY: (json['gyro_y'] ?? json['gyroY'])?.toDouble(),
      gyroZ: (json['gyro_z'] ?? json['gyroZ'])?.toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      altitude: (json['altitude'])?.toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  // Create a copy with updated values
  SensorReadings copyWith({
    int? lightIntensity,
    double? noiseLevel,
    double? pressure,
    double? temperature,
    double? accX,
    double? accY,
    double? accZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    double? latitude,
    double? longitude,
    double? altitude,
    DateTime? timestamp,
  }) {
    return SensorReadings(
      lightIntensity: lightIntensity ?? this.lightIntensity,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      pressure: pressure ?? this.pressure,
      temperature: temperature ?? this.temperature,
      accX: accX ?? this.accX,
      accY: accY ?? this.accY,
      accZ: accZ ?? this.accZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'SensorReadings('
        'light: $lightIntensity lux, '
        'noise: $noiseLevel dB, '
        'pressure: $pressure hPa, '
        'temp: $temperature °C, '
        'acc: ($accX, $accY, $accZ) m/s², '
        'gyro: ($gyroX, $gyroY, $gyroZ) rad/s, '
        'lat: $latitude, lng: $longitude, alt: $altitude m, '
        'time: $timestamp)';
  }
}
