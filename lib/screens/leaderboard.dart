// lib/screens/leaderboard_screen.dart
import 'package:ecosense/models/user.dart';
import 'package:ecosense/services/data_service.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  // For TabController
  late TabController _tabController;
  List<UserProfile> _leaderboardData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final int _topLimit = 50; // Fetch top 50 users

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // 3 tabs: Global, Local, Friends
    _loadLeaderboard(); // Load global leaderboard by default
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Loads the leaderboard data based on the currently selected tab.
  /// For now, we'll only implement Global.
  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _leaderboardData.clear();
    });

    try {
      // In a real app, you'd determine which tab is selected and call the appropriate method
      // For simplicity, we'll fetch the global leaderboard.
      // You can extend this later for Local (based on user's location) and Friends (based on user's friend list).
      List<UserProfile> users = await DataService().fetchLeaderboard(
        limit: _topLimit,
      );

      setState(() {
        _leaderboardData = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load leaderboard. Please try again.';
      });
    }
  }

  /// Refreshes the leaderboard data.
  Future<void> _refreshLeaderboard() async {
    await _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF101910)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF101910)),
            onPressed: _refreshLeaderboard,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color.fromARGB(43, 16, 25, 16), width: 1),
                ),
              ),
            ),
          ),
          Expanded(child: _buildLeaderboardTab(context)),
        ],
      ),
    );
  }

  /// Builds the content for a leaderboard tab (currently only Global is fully implemented).
  Widget _buildLeaderboardTab(BuildContext context) {
    // Use FutureBuilder or manage state directly as we are doing
    // Since we load data in initState and on refresh, direct state management is okay for now.
    // FutureBuilder would be useful if this tab loaded data independently.

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    } else if (_leaderboardData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('No leaderboard data available yet.'),
            Text('Start contributing to climb the ranks!'),
          ],
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _leaderboardData.length,
        itemBuilder: (context, index) {
          final user = _leaderboardData[index];
          final int rank = index + 1; // Ranks start from 1
          return _buildLeaderboardItem(context, user, rank);
        },
      );
    }
  }

  /// Builds a single item (row) in the leaderboard list.
  Widget _buildLeaderboardItem(
    BuildContext context,
    UserProfile user,
    int rank,
  ) {
    // Determine rank-specific styling (Top 3 get special treatment)
    Color rankColor = Colors.black87;
    IconData? rankIcon;
    Color? rankIconColor;
    Color? rankBackgroundColor;
    double rankFontSize = 18.0;

    if (rank == 1) {
      rankColor = Colors.orange;
      rankIcon = Icons.workspace_premium; // Trophy icon
      rankIconColor = Colors.orange;
      rankBackgroundColor = Colors.orange.shade50;
      rankFontSize = 22.0;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade600;
      rankIcon = Icons.workspace_premium_outlined; // Silver trophy
      rankIconColor = Colors.grey;
      rankBackgroundColor = Colors.grey.shade100;
      rankFontSize = 20.0;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade600;
      rankIcon = Icons.workspace_premium_outlined; // Bronze trophy
      rankIconColor = Colors.brown;
      rankBackgroundColor = Colors.brown.shade50;
      rankFontSize = 19.0;
    }

    return Card(
      color: Color(0xFFF9FBF9),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        // --- Rank Number ---
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: rankBackgroundColor ?? Colors.transparent,
            shape: BoxShape.circle,
            border: rank == 1 || rank == 2 || rank == 3
                ? Border.all(
                    color: rankIconColor ?? Colors.transparent,
                    width: 2,
                  )
                : null,
          ),
          child: rankIcon != null
              ? Icon(rankIcon, color: rankIconColor, size: 30)
              : Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: rankFontSize,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
        ),
        // --- User Info ---
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis, // Handle long names
        ),
        subtitle: Text(
          '${user.points} points',
          style: const TextStyle(color: Colors.grey),
        ),
        // --- Profile Picture (Placeholder) ---
        trailing: CircleAvatar(
          radius: 20,
          // backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? const Icon(Icons.person, size: 20)
              : null,
        ),
      ),
    );
  }
}
