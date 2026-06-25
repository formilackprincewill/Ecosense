
class DataPoint {
  final String dataId; // Firestore document ID
  final String userId; // UID of the submitting user
  final String submittedByName; // Name of the submitting user (for display)
  final double latitude;
  final double longitude;
  final double? pressure; // hPa
  final double? noiseLevel; // dB
  final int? lightIntensity; // lux
  final DateTime timestamp; // Time of data collection
  final DateTime submittedAt; // Time of submission to server

  DataPoint({
    required this.dataId,
    required this.userId,
    required this.submittedByName,
    required this.latitude,
    required this.longitude,
    this.pressure,
    this.noiseLevel,
    this.lightIntensity,
    required this.timestamp,
    required this.submittedAt,
  });

  // Factory constructor to create a DataPoint from a JSON map (Supabase)
  factory DataPoint.fromJson(Map<String, dynamic> data) {
    // Handle nested 'location' object or flat lat/lng depending on your SQL schema
    double lat = 0.0;
    double lng = 0.0;
    
    if (data['location'] != null && data['location'] is Map) {
      lat = (data['location']['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (data['location']['longitude'] as num?)?.toDouble() ?? 0.0;
    } else {
      lat = (data['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    // Handle nested 'readings' object or flat fields
    Map<String, dynamic> readings = data['readings'] != null && data['readings'] is Map 
        ? data['readings'] as Map<String, dynamic> 
        : data;

    return DataPoint(
      dataId: data['id'] ?? data['dataId'] ?? '',
      userId: data['userId'] ?? data['author_id'] ?? 'Unknown User',
      submittedByName: data['submittedByName'] ?? 'Unknown',
      latitude: lat,
      longitude: lng,
      pressure: (readings['pressure'] as num?)?.toDouble() ?? (readings['air_quality'] as num?)?.toDouble(),
      noiseLevel: (readings['noise_level'] ?? readings['noiseLevel'] as num?)?.toDouble(),
      lightIntensity: (readings['light_intensity'] ?? readings['lightIntensity'] as num?)?.toInt(),
      timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
      submittedAt: DateTime.tryParse(data['submittedAt']?.toString() ?? data['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
