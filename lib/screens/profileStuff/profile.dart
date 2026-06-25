import 'package:ecosense/models/data_point.dart';
import 'package:ecosense/providers/auth_provider.dart';
import 'package:ecosense/screens/auth/wrapper.dart';
import 'package:ecosense/screens/profileStuff/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Future<void> _saveSetting(String key, bool value) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(key, value);
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = context
        .watch<AuthProvider>(); // u could also use provider.of(context)

    void navigateToEditProfile() {
      // Navigator.pushNamed(context, '/edit_profile');EditProfileScreen
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Edit Profile feature coming soon!')),
      // );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
      );
    }

    /// Check if user data is available
    // if (authProvider.user == null) {
    //   // Navigator.of(
    //   //   context,
    //   // ).push(MaterialPageRoute(builder: (context) => SignInPage()));
    //   // Handle case where user data hasn't loaded yet or user is not logged in
    //   // This might happen briefly during app startup or after logout
    //   print("User id is null");
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()), // Or an error message
    //   );
    // }

    // User data is available, display it
    // final User user =
    // authProvider.user!; // Safe to unwrap because we checked for null

    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        actions: [
          // Edit Profile Icon Button
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF101910)),
            onPressed: navigateToEditProfile,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF101910)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await authProvider.refreshUserProfileAndHistory();
        },
        child: ListView(
          children: [
            if (authProvider.userProfile != null) ...[
              // Profile Info
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      // backgroundImage: NetworkImage(
                      //   'https://picsum.photos/seed/sophia/200', // Placeholder image
                      // ),
                      backgroundColor: Color(0xFFEAF1E9),
                      child: Icon(
                        Icons.person,
                        size: 64,
                        color: Color(0xFF5C8E57),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      authProvider.userProfile!.name,
                      style: TextStyle(
                        color: Color(0xFF101910),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      authProvider.userProfile!.email,
                      style: TextStyle(color: Color(0xFF5C8E57), fontSize: 16),
                    ),
                    Text(
                      'Joined 2025',
                      style: TextStyle(color: Color(0xFF5C8E57), fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Stats
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFD4E4D3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${authProvider.contributionHistory.length}", // "${user.points}",
                              style: TextStyle(
                                color: Color(0xFF101910),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Contributions',
                              style: TextStyle(
                                color: Color(0xFF5C8E57),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFD4E4D3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${authProvider.userProfile!.points}',
                              style: TextStyle(
                                color: Color(0xFF101910),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Points',
                              style: TextStyle(
                                color: Color(0xFF5C8E57),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              const Center(child: CircularProgressIndicator()),
            // History Section
            Container(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              alignment: Alignment.centerLeft,
              child: Text(
                'Contribution History',
                style: TextStyle(
                  color: Color(0xFF101910),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // History Items
            SizedBox(
              height: 200,
              child: Consumer<AuthProvider>(
                builder: (context, authProv, child) {
                  if (authProv.contributionHistory.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text('No contributions yet.'),
                          Text('Start scanning to add data!'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Important for ListView inside Column
                    physics:
                        const ClampingScrollPhysics(), // Or BouncingScrollPhysics
                    itemCount: authProv.contributionHistory.length,
                    itemBuilder: (context, index) {
                      final dataPoint = authProv.contributionHistory[index];
                      return _buildHistoryItem(context, dataPoint);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // _buildHistoryItem(
            //   Icons.air_outlined,
            //   'Air Quality Index',
            //   '2023-08-15',
            // ),
            // _buildHistoryItem(
            //   Icons.water_drop_outlined,
            //   'Water pH Level',
            //   '2023-08-10',
            // ),
            // _buildHistoryItem(
            //   Icons.volume_up_outlined,
            //   'Noise Pollution',
            //   '2023-08-05',
            // ),
            // _buildHistoryItem(
            //   Icons.eco_outlined,
            //   'Biodiversity Index',
            //   '2023-07-28',
            // ),

            // Logout Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: OutlinedButton(
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text('Logout'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    await authProvider.signOut();
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const AuthWrapper(),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xFFEAF1E9),
                  foregroundColor: Color(0xFF101910),
                  minimumSize: Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  side: BorderSide.none,
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, DataPoint dataPoint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 72,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFFEAF1E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForPrimaryReading(dataPoint),
              color: _getColorForPrimaryReading(dataPoint),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_getPrimaryReadingLabel(dataPoint)}: ${_getPrimaryReadingValue(dataPoint)}',
                  style: TextStyle(
                    color: Color(0xFF101910),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat.yMMMd().add_jm().format(dataPoint.timestamp),
                  style: TextStyle(color: Color(0xFF5C8E57), fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper methods for Contribution Item ---
  IconData _getIconForPrimaryReading(DataPoint dataPoint) {
    // Prioritize Pressure, then Noise, then Light
    if (dataPoint.pressure != null) return Icons.speed;
    if (dataPoint.noiseLevel != null) return Icons.volume_up;
    if (dataPoint.lightIntensity != null) return Icons.wb_sunny;
    return Icons.question_mark; // Fallback
  }

  Color _getColorForPrimaryReading(DataPoint dataPoint) {
    // Prioritize Pressure, then Noise, then Light for color
    if (dataPoint.pressure != null) {
      return _getPressureColor(dataPoint.pressure);
    }
    if (dataPoint.noiseLevel != null) {
      return _getNoiseColor(dataPoint.noiseLevel);
    }
    if (dataPoint.lightIntensity != null) {
      return _getLightColor(dataPoint.lightIntensity);
    }
    return Colors.grey; // Fallback
  }

  static Color _getPressureColor(double? pressure) {
    if (pressure == null) return Colors.grey;
    if (pressure < 1000) return Colors.blue;
    if (pressure < 1013) return Colors.green;
    if (pressure < 1025) return Colors.yellow;
    return Colors.orange;
  }

  static Color _getNoiseColor(double? noise) {
    if (noise == null) return Colors.grey;
    if (noise < 40) return Colors.green; // Quiet
    if (noise < 60) return Colors.yellow; // Normal Conversation
    if (noise < 80) return Colors.orange; // Busy Traffic
    return Colors.red; // Loud
  }

  static Color _getLightColor(int? light) {
    if (light == null) return Colors.grey;
    if (light < 50) return Colors.blueGrey; // Dark
    if (light < 200) return Colors.blue; // Dim
    if (light < 1000) return Colors.green; // Normal Indoor
    if (light < 5000) return Colors.yellow; // Bright Indoor
    return Colors.orange; // Very Bright / Outdoor Sunlight
  }

  String _getPrimaryReadingLabel(DataPoint dataPoint) {
    if (dataPoint.pressure != null) return 'Pressure';
    if (dataPoint.noiseLevel != null) return 'Noise';
    if (dataPoint.lightIntensity != null) return 'Light';
    return 'Data';
  }

  String _getPrimaryReadingValue(DataPoint dataPoint) {
    if (dataPoint.pressure != null) {
      return '${dataPoint.pressure!.toStringAsFixed(1)} hPa';
    }
    if (dataPoint.noiseLevel != null) {
      return '${dataPoint.noiseLevel!.toStringAsFixed(1)} dB';
    }
    if (dataPoint.lightIntensity != null) {
      return '${dataPoint.lightIntensity} lux';
    }
    return 'N/A';
  }

  // Widget _buildToggleSetting(
  //   String title,
  //   bool value,
  //   Function(bool) onChanged,
  // ) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     height: 56,
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Text(
  //             title,
  //             style: TextStyle(color: Color(0xFF101910), fontSize: 16),
  //           ),
  //         ),
  //         Switch(
  //           value: value,
  //           onChanged: onChanged,
  //           activeThumbColor: Color(0xFF298321),
  //           inactiveTrackColor: Color(0xFFEAF1E9),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNavigationSetting(String title, Function() onTap) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     height: 56,
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Text(
  //             title,
  //             style: TextStyle(color: Color(0xFF101910), fontSize: 16),
  //           ),
  //         ),
  //         IconButton(
  //           onPressed: onTap,
  //           icon: Icon(
  //             Icons.arrow_forward_ios,
  //             color: Color(0xFF101910),
  //             size: 24,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
