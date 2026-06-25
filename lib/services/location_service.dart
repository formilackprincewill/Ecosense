import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Request location permissions
  Future<bool> requestLocationPermission() async {
    final permissionStatus = await Permission.location.request();
    return permissionStatus.isGranted;
  }

  // Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    final permissionStatus = await Permission.location.status;
    return permissionStatus.isGranted;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check permissions
    bool hasPermission = await hasLocationPermission();
    if (!hasPermission) {
      bool granted = await requestLocationPermission();
      if (!granted) {
        throw Exception('Location permission denied');
      }
    }

    try {
      // Get current position with high accuracy
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      // Fallback to medium accuracy if high accuracy fails
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
    }
  }

  // Get location with error handling
  Future<Position?> getCurrentLocationSafely() async {
    try {
      return await getCurrentLocation();
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two positions
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Get location settings for the app
  LocationSettings getLocationSettings() {
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update when moved 10 meters
    );
  }

  // Listen to location changes
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: getLocationSettings(),
    );
  }

  // Convert coordinates to a human-readable string
  String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Get a simplified location name (would normally use geocoding)
  String getLocationName(double latitude, double longitude) {
    // In a real app, you would use a geocoding service
    // For demo purposes, we'll return a simplified format
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lonDirection = longitude >= 0 ? 'E' : 'W';

    return '${latitude.abs().toStringAsFixed(2)}°$latDirection, ${longitude.abs().toStringAsFixed(2)}°$lonDirection';
  }

  // Check if location is accurate enough for data collection
  bool isLocationAccurate(Position position, {double maxAccuracy = 20.0}) {
    return position.accuracy <= maxAccuracy;
  }
}
