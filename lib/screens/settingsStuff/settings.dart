// settings_screen.dart
import 'package:ecosense/screens/privacy_policy_screen.dart';
import 'package:ecosense/screens/settingsStuff/change_password.dart';
import 'package:ecosense/screens/terms_of_service_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Example settings state
  bool _notificationsEnabled = true;

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      // TODO: Save preference
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF101910)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C8E57),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsToggle(
              title: "Notifications",
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),

            const SizedBox(height: 24),

            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C8E57),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsButton(
              title: "Change Password",
              icon: Icons.lock_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Changepassword(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildSettingsButton(
              title: "Privacy Policy",
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                // Open Privacy Policy URL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildSettingsButton(
              title: "Terms of Service",
              icon: Icons.description_outlined,
              onTap: () {
                // Open Terms of Service URL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C8E57),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsButton(
              title: "Version 1.0.0",
              icon: Icons.info_outline,
              onTap: () {
                // Show app info/version details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('EcoSense v1.0.0')),
                );
              },
            ),
          ],
        ),
      ),
      // persistentFooterButtons: [
      //   Container(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Center(
      //       child: Text(
      //         '© 2026 EcoSense. All rights reserved.',
      //         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  Widget _buildSettingsToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF101910)),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF2E7D32),
            ),
          ],
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 0.0, top: 4.0),
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5C8E57)),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEAF1E9), width: 1.0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5C8E57)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF101910)),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF5C8E57),
            ),
          ],
        ),
      ),
    );
  }
}
