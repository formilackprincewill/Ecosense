import 'dart:convert';
import 'package:ecosense/models/sensor_readings.dart';
import 'package:http/http.dart' as http;
import '../models/analytics_models.dart';

class AnalyticsApiService {
  final String baseUrl = "https://localhost:7238/api";

  /// Pulls structured mathematical telemetry metrics from the backend C# controller
  Future<AnalyticsResult> fetchSensorInsights() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Analytics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AnalyticsResult.fromJson(data);
      } else {
        throw Exception('Failed to load insight matrix: Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network pipeline exception: $e');
    }
  }

  /// Formats raw Supabase readings into standardized CSV data payloads for client-side exporting
  String generateCsv(List<SensorData> data) {
    final List<String> headers = ['User ID', 'Noise (dB)', 'Light (Lux)', 'Pressure (hPa)', 'Location'];
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(headers.join(','));
    
    for (var row in data) {
      final locStr = '"${row.readings.latitude}, ${row.readings.longitude}"' ;
      final List<dynamic> cells = [
        '"${row.userId}"',
        row.readings.noiseLevel,
        row.readings.lightIntensity,
        row.readings.pressure,
        locStr
      ];
      buffer.writeln(cells.join(','));
    }
    return buffer.toString();
  }
}
// lib/models/analytics_models.dart

// Add this class to your existing file to satisfy the Supabase mapped collection requirement:
class SensorData {
  final String userId;
  final SensorReadings readings;

  SensorData({
    required this.userId,
    required this.readings,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      userId: json['user_id'] ?? json['userId'] ?? 'Unknown Node',
      readings: SensorReadings.fromJson(json),
    );
  }
}