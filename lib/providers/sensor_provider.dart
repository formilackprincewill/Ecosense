// lib/providers/sensor_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart'; // For ChangeNotifier
import '../services/sensor_manager.dart';
import '../models/sensor_readings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class SensorProvider with ChangeNotifier {
  final SensorManager _sensorManager = SensorManager();

  static const String _cachedDataKey = 'offline_sensor_data_queue';

  SensorReadings get currentReadings => _sensorManager.currentReadings;
  bool get isCapturing => _sensorManager.isCapturing;

  SensorProvider() {
    // Listen to updates from the SensorManager
    _sensorManager.onReadingsUpdated = () {
      // When SensorManager updates readings, notify listeners of this provider
      notifyListeners();
    };
  }
  final _supabase = Supabase.instance.client;

  Future<void> startCapturing() async {
    await _sensorManager.startCapturing();
    // notifyListeners is called by _sensorManager.onReadingsUpdated
  }

  Future<void> stopCapturing() async {
    await _sensorManager.stopCapturing();
    notifyListeners(); // Ensure UI knows capturing has stopped
  }

  @override
  void dispose() {
    _sensorManager.dispose();
    super.dispose();
  }

  /// Returns a map indicating success/failure.
  Future<Map<String, dynamic>> submitDataAndAwardPoints({
    required String userId, // The Firebase User ID
    required double latitude,
    required double longitude,
    // Use types that match your SensorReadings model and API expectations
    // Based on EcoSense_API_Documentation.pdf, these should be numbers
    double? pressure, // AQI or proxy value (integer)
    double? noiseLevel, // dB (double)
    int? lightIntensity, // lux (integer)
    required DateTime timestamp,
  }) async {
    if (kDebugMode) {
      print(
      'DEBUG SensorProvider.submitDataAndAwardPoints: Method called.',
    );
    } // <-- ADD THIS
    if (kDebugMode) {
      print(
      'DEBUG SensorProvider.submitDataAndAwardPoints: Parameters - userId=$userId, lat=$latitude, lng=$longitude, aqi=$pressure, noise=$noiseLevel, light=$lightIntensity, ts=$timestamp',
    );
    }
    // --- 1. Check Network Connectivity ---
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.none)) {
      //connectivityResult == ConnectivityResult.none
      // --- OFFLINE MODE ---
      bool cached = await _cacheDataLocally({
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
        'pressure': pressure,
        'noiseLevel': noiseLevel,
        'lightIntensity': lightIntensity,
        'timestamp': timestamp
            .toUtc()
            .toIso8601String(), // Store as ISO string for consistency
      });

      if (cached) {
        return {
          'success': true,
          'message': 'Data cached locally. Will be submitted when online.',
          'wasCached': true, // Indicate it was cached, not submitted
        };
      } else {
        return {'success': false, 'error': 'Failed to cache data locally.'};
      }
    } else {
      // --- ONLINE MODE ---
      final result = await _submitDataOnline(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        pressure: pressure,
        noiseLevel: noiseLevel,
        lightIntensity: lightIntensity,
        timestamp: timestamp,
      );

      // If online submission was successful, also check and submit any cached data
      if (result['success'] == true) {
        // Use unawaited or run in the background to avoid blocking the UI thread
        // for the sync process. The sync itself can be fire-and-forget.
        // Alternatively, await it if you want to ensure it completes before returning.
        // For now, we'll fire it off.
        _attemptSubmitCachedData(); // Attempt to sync cached data in the background
      }

      return result;
    }
  }

  /// Submits data to Firestore when online.
  /// This encapsulates the core logic you already had for online submission.
  Future<Map<String, dynamic>> _submitDataOnline({
    required String userId,
    required double latitude,
    required double longitude,
    double? pressure,
    double? noiseLevel,
    int? lightIntensity,
    required DateTime timestamp,
  }) async {
    try {
      // --- 1. Prepare data point for Supabase ---
      final dataPoint = {
        'author_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'pressure': pressure,
        'noise_level': noiseLevel,
        'light_intensity': lightIntensity,
        'timestamp': timestamp.toIso8601String(), 
        // created_at or submittedAt should be handled by default NOW() in DB
      };

      // --- 2. Add document to 'data_points' table in Supabase ---
      final response = await _supabase
          .from('data_points')
          .insert(dataPoint)
          .select()
          .single();

      // --- 3. Award Points to the User ---
      // Supabase atomicity can be done with RPC. Without it, we fetch and increment explicitly.
      try {
        final userResult = await _supabase
            .from('users')
            .select('points')
            .eq('id', userId)
            .maybeSingle();

        if (userResult != null) {
          int currentPoints = userResult['points'] ?? 0;
          await _supabase
              .from('users')
              .update({'points': currentPoints + 10})
              .eq('id', userId);
        }

        return {
          'success': true,
          'message': 'Data submitted successfully! 10 points awarded!',
          'data_id': response['id'],
        };
      } catch (pointsError) {
        return {
          'success': true, 
          'message': 'Data submitted, but there was an issue awarding points. Please refresh your profile.',
          'data_id': response['id'],
          'pointsError': pointsError.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred during data submission: $e',
      };
    }
  }

  /// Caches data locally using shared_preferences when offline.
  ///
  /// [dataToCache] A map containing the data point details to be cached.
  /// Returns true if caching was successful, false otherwise.
  Future<bool> _cacheDataLocally(Map<String, dynamic> dataToCache) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Retrieve existing cached list (stored as JSON strings)
      List<String>? cachedListJson = prefs.getStringList(_cachedDataKey) ?? [];
      // Convert JSON strings back to Maps
      List<Map<String, dynamic>> cachedList = cachedListJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      // Add the new data point to the list
      cachedList.add(dataToCache);

      // Convert the updated list back to JSON strings
      List<String> updatedListJson = cachedList
          .map((item) => jsonEncode(item))
          .toList();

      // Save the updated list back to SharedPreferences
      bool success = await prefs.setStringList(_cachedDataKey, updatedListJson);
      if (success) {
      } else {}
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Attempts to submit all cached data points when connectivity is restored.
  /// This method iterates through the cached list, submits each item online,
  /// and removes successfully submitted items from the cache.
  Future<void> _attemptSubmitCachedData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? cachedListJson = prefs.getStringList(_cachedDataKey);

      // If there's no cached data, nothing to do.
      if (cachedListJson == null || cachedListJson.isEmpty) {
        return;
      }

      // Convert JSON strings back to Maps for processing
      List<Map<String, dynamic>> cachedList = cachedListJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      // Keep track of items that failed to submit and need to stay in the cache
      List<Map<String, dynamic>> stillFailedItems = [];

      // Iterate through each cached data point
      for (Map<String, dynamic> cachedData in cachedList) {
        // Reconstruct parameters from the cached map
        // Ensure types are correctly cast
        String userId = cachedData['userId'];
        double lat = (cachedData['latitude'] as num).toDouble();
        double lng = (cachedData['longitude'] as num).toDouble();
        double? pressure = cachedData['pressure'] is double
            ? cachedData['pressure']
            : (cachedData['pressure'] as num?)?.toDouble();
        double? noise = cachedData['noiseLevel'] is double
            ? cachedData['noiseLevel']
            : (cachedData['noiseLevel'] as num?)?.toDouble();
        int? light = cachedData['lightIntensity'] is int
            ? cachedData['lightIntensity']
            : (cachedData['lightIntensity'] as num?)?.toInt();
        // Parse the timestamp string back to DateTime
        DateTime ts = DateTime.parse(cachedData['timestamp']);

        // Call the online submission method with the reconstructed data
        final result = await _submitDataOnline(
          userId: userId,
          latitude: lat,
          longitude: lng,
          pressure: pressure,
          noiseLevel: noise,
          lightIntensity: light,
          timestamp: ts,
        );

        // Check the result of the submission attempt
        if (result['success'] != true) {
          // If submission failed, log it and keep the item for the next sync attempt
          stillFailedItems.add(cachedData); // Add to list of items to retain
        } else {
          // If submission succeeded, log it (it's implicitly removed from the cache)
        }
      }

      // --- Update Local Cache ---
      // After processing, update the cache to only contain items that failed.
      if (stillFailedItems.isEmpty) {
        // If all items were submitted successfully, clear the entire cache entry
        await prefs.remove(_cachedDataKey);
      } else {
        // If some items failed, serialize the `stillFailedItems` list and save it back
        List<String> updatedListJson = stillFailedItems
            .map((item) => jsonEncode(item))
            .toList();
        await prefs.setStringList(_cachedDataKey, updatedListJson);
      }
    } catch (e) {
      // Handle any unexpected errors during the sync process
      // Don't clear the cache on error, as items might succeed on the next attempt
      // Optionally, show a user-facing error message or notification
    }
  }
}
