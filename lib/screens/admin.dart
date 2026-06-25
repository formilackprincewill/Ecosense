import 'package:flutter/material.dart';

class AdminPanel extends StatelessWidget {
  final List<Map<String, dynamic>> users = [
    {
      'name': 'Olivia Smith',
      'email': 'olivia.smith@email.com',
      'contributions': 120,
      'image': 'https://picsum.photos/seed/olivia/200',
    },
    {
      'name': 'Liam Jones',
      'email': 'liam.jones@email.com',
      'contributions': 85,
      'image': 'https://picsum.photos/seed/liam/200',
    },
    {
      'name': 'Emma Davis',
      'email': 'emma.davis@email.com',
      'contributions': 210,
      'image': 'https://picsum.photos/seed/emma/200',
    },
    {
      'name': 'Noah Wilson',
      'email': 'noah.wilson@email.com',
      'contributions': 55,
      'image': 'https://picsum.photos/seed/noah/200',
    },
    {
      'name': 'Ava Brown',
      'email': 'ava.brown@email.com',
      'contributions': 15,
      'image': 'https://picsum.photos/seed/ava/200',
    },
  ];

  AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF101910),
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Color(0xFF101910),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48), // Spacer for alignment
              ],
            ),
          ),

          // Tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFD4E4D3), width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildTab('Users', true),
                _buildTab('Reports', false),
                _buildTab('Stats', false),
              ],
            ),
          ),

          // User List
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildUserCard(users[index]);
              },
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      margin: EdgeInsets.only(right: 32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? Color(0xFF298321) : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Color(0xFF101910) : Color(0xFF5C8E57),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 72,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(user['image']),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(
                    color: Color(0xFF101910),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user['email'],
                  style: TextStyle(color: Color(0xFF5C8E57), fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${user['contributions']} contributions',
            style: TextStyle(color: Color(0xFF101910), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
