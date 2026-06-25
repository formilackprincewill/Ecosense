// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecosense/models/data_point.dart';
import 'package:ecosense/models/user.dart';
import 'package:ecosense/services/data_service.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  User? get user => _supabase.auth.currentUser;
  UserProfile? _userProfile;
  List<DataPoint> _contributionHistory = [];

  UserProfile? get userProfile => _userProfile;
  List<DataPoint> get contributionHistory => _contributionHistory;
  bool get isLoggedIn => user != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _fetchUserProfile(session.user.id);
        await _fetchContributionHistory(session.user.id);
      } else {
        _userProfile = null;
        _contributionHistory.clear();
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final response = await _supabase.from('users').select().eq('id', userId).maybeSingle();
      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
      } else {
        if (user != null) {
          final newProfileMap = {
            'id': user!.id,
            'email': user!.email ?? 'No Email',
            'display_name': user!.userMetadata?['display_name'] ?? 'Anonymous',
            'points': 0,
          };
          await _supabase.from('users').upsert(newProfileMap);
          _userProfile = UserProfile.fromJson(newProfileMap);
        } else {
          _userProfile = null;
        }
      }
    } catch (e) {
      _userProfile = null;
    }
  }

  Future<void> refreshUserProfile() async {
    if (user != null) {
      await _fetchUserProfile(user!.id);
      notifyListeners();
    }
  }

  Future<void> _fetchContributionHistory(String userId) async {
    try {
      _contributionHistory = await DataService().fetchUserDataPoints(userId, limit: 50);
    } catch (e) {
      _contributionHistory = [];
    }
  }

  Future<void> refreshUserProfileAndHistory() async {
    if (user != null) {
      await _fetchUserProfile(user!.id);
      await _fetchContributionHistory(user!.id);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );
      if (res.user != null) {
        // Explicitly insert into standard public table
        await _supabase.from('users').upsert({
          'id': res.user!.id,
          'email': email,
          'display_name': name,
          'points': 0,
        });

        return {'success': true, 'user': res.user};
      }
      return {'success': false, 'error': 'Registration succeeded but user object is null.'};
    } on AuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
       final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) return {'success': true, 'user': res.user};
      return {'success': false, 'error': 'Login succeeded but user object is null.'};
    } on AuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred during login.'};
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return {'success': true, 'message': 'Password reset email sent successfully!'};
    } on AuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred.'};
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final res = await _supabase.from('users').select().eq('id', userId).maybeSingle();
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getLatestData({
    double? latitude,
    double? longitude,
    double? radiusKm,
    int limit = 100,
  }) async {
    try {
      var query = _supabase.from('data_points').select();
      
      if (latitude != null && longitude != null && radiusKm != null) {
        double latDelta = radiusKm / 111.0;
        double lngDelta = radiusKm / (111.0 * 1); // approximate
        query = query
            .gte('latitude', latitude - latDelta)
            .lte('latitude', latitude + latDelta)
            .gte('longitude', longitude - lngDelta)
            .lte('longitude', longitude + lngDelta);
      }
      
      final res = await query.order('timestamp', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final success = await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      if (success) {
        return {'success': true}; 
      }
      return {'success': false, 'error': 'Google Sign-In failed.'};
    } catch(e) {
       return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? email,
  }) async {
    if (user == null) return {'success': false, 'error': 'No user logged in.'};
    try {
      Map<String, dynamic> map = {};
      if (name != null) map['display_name'] = name;
      
      if (map.isNotEmpty) {
        await _supabase.from('users').update(map).eq('id', user!.id);
      }
      return {'success': true};
    } on PostgrestException catch(e) {
      return {'success': false, 'error': e.message};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
     try {
       await _supabase.auth.updateUser(UserAttributes(password: newPassword));
       return {'success': true};
     } on AuthException catch(e) {
       return {'success': false, 'error': e.message};
     } catch(e) {
       return {'success': false, 'error': e.toString()};
     }
  }
}
