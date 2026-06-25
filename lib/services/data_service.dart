import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecosense/models/data_point.dart';
import 'package:ecosense/models/user.dart';

class DataService {
  final _supabase = Supabase.instance.client;

  /// Fetches the latest global environmental data points.
  ///
  /// [limit] The maximum number of data points to fetch.
  /// Returns a Future that resolves to a list of DataPoint objects.
  Future<List<DataPoint>> fetchLatestGlobalData({int limit = 20}) async {
    try {
      final List<dynamic> data = await _supabase
          .from('data_points')
          .select()
          .order('timestamp', ascending: false)
          .limit(limit);

      return data.map((json) => DataPoint.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetches the top users based on points.
  ///
  /// [limit] The maximum number of users to fetch (e.g., top 50).
  /// Returns a Future that resolves to a list of UserProfile objects.
  Future<List<UserProfile>> fetchLeaderboard({int limit = 50}) async {
    try {
      final List<dynamic> data = await _supabase
          .from('users')
          .select()
          .order('points', ascending: false)
          .limit(limit);

      return data.map((json) => UserProfile.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return []; 
    }
  }

  /// Fetches the single most recent global data point.
  ///
  /// Returns a Future that resolves to a DataPoint object, or null if no data exists.
  Future<DataPoint?> fetchMostRecentGlobalDataPoint() async {
    try {
      final List<dynamic> data = await _supabase
          .from('data_points')
          .select()
          .order('timestamp', ascending: false)
          .limit(1);

      if (data.isNotEmpty) {
        return DataPoint.fromJson(data.first as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Fetches data points submitted by a specific user.
  /// [userId] The Supabase User ID.
  /// [limit] The maximum number of data points to fetch.
  /// Returns a Future that resolves to a list of DataPoint objects.
  Future<List<DataPoint>> fetchUserDataPoints(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final List<dynamic> data = await _supabase
          .from('data_points')
          .select()
          .eq('author_id', userId) 
          .order('timestamp', ascending: false)
          .limit(limit);

      return data.map((json) => DataPoint.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return []; 
    }
  }
}
