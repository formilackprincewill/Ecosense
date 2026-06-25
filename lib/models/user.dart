
class UserProfile {
  final String userId; // Firebase UID
  final String name;
  final String email;
  final int points;
  final String? photoUrl; // If used
  // Add other fields like createdAt, badges if needed for Home Dashboard display

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.points,
    this.photoUrl,
  });

  /// Factory constructor to create a UserProfile from a JSON Map
  factory UserProfile.fromJson(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['id'] ?? data['userId'] ?? '', 
      name: data['name'] ?? data['display_name'] ?? 'Anonymous',
      email: data['email'] ?? 'No Email',
      points: data['points'] ?? 0,
      photoUrl: data['photoUrl'] ?? data['avatar_url'], 
    );
  }

    /// Creates a copy of this UserProfile but with the given fields replaced with the new values.
  UserProfile copyWith({
    String? name,
    String? email,
    int? points,
    String? photoUrl,
    // Add other fields
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      points: points ?? this.points,
      photoUrl: photoUrl ?? this.photoUrl,
      // Copy other fields
    );
  }
}
