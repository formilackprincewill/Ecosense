import 'package:ecosense/screens/dash.dart';
import 'package:ecosense/screens/leaderboard.dart';
import 'package:ecosense/screens/profileStuff/profile.dart';
import 'package:ecosense/screens/sensor_insights_screen.dart';
import 'package:ecosense/screens/settingsStuff/settings.dart';
import 'package:flutter/material.dart';

class NavWrapper extends StatefulWidget {
  const NavWrapper({super.key});

  @override
  State<NavWrapper> createState() => _NavWrapperState();
}

class _NavWrapperState extends State<NavWrapper> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomePage(),
    LeaderboardScreen(),
    SensorInsightsScreen(),
    SettingsScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF9FBF9),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 16, top: 6),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: const Color(0xFFEAF1E9), width: 1)),
          color: const Color(0xFFF9FBF9),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFF9FBF9),
          iconSize: 30,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF5C8E57),
          unselectedItemColor: const Color(0xFF101910),
          elevation: 0,
          onTap: _navigateBottomBar,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              label: "Leaderboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: "Insights",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
