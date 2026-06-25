import 'package:ecosense/models/data_point.dart';
import 'package:ecosense/screens/data_export_screen.dart';
import 'package:ecosense/screens/map.dart';
import 'package:ecosense/screens/sensor_reading.dart';
import 'package:ecosense/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:ecosense/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>(); // u could also use provider.of(context)

    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      body: ListView(
        children: [
          // Header
          if (authProvider.userProfile != null) ...[
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "Hi, ${authProvider.userProfile!.name}", // 'Hi, ${user.name}',
                        style: TextStyle(
                          color: Color(0xFF101910),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DataExportScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.cloud_download_rounded,
                        color: Color(0xFF101910),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFEAF1E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          color: Color(0xFF101910),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${authProvider.userProfile!.points}',
                          style: TextStyle(
                            color: Color(0xFF101910),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
          // Metrics Cards
          Container(
            padding: EdgeInsets.all(16),
            child: FutureBuilder<DataPoint?>(
              future: DataService().fetchMostRecentGlobalDataPoint(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading placeholders for stat cards
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data != null) {
                  final DataPoint latestPoint = snapshot.data!;
                  return Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Pressure',
                          latestPoint.pressure != null ? '${latestPoint.pressure!.toStringAsFixed(1)} hPa' : 'N/A',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Noise Level',
                          '${latestPoint.noiseLevel?.toStringAsFixed(1) ?? 'N/A'} dB',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Light Intensity',
                          '${latestPoint.lightIntensity ?? 'N/A'} lux',
                        ),
                      ),
                    ],
                  );
                } else {
                  // No data available
                  return Row(
                    children: [
                      Expanded(child: _noDataStatCard(title: 'Pressure')),
                      SizedBox(width: 15),
                      Expanded(child: _noDataStatCard(title: 'Noise')),
                    ],
                  );
                }
              },
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LiveSensorReadingsPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF298321),
                      foregroundColor: Color(0xFFF9FBF9),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Start Scan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement<void, void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const GlobalMapViewScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFFEAF1E9),
                      foregroundColor: Color(0xFF101910),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Map',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Latest Contributions Title
          Container(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Latest Contributions',
                style: TextStyle(
                  color: Color(0xFF101910),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Contributions List
          Container(
            height: 220,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _buildContributionItem(
              'images/sound.png',
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFFEAF1E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF101910),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF101910),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionItem(String imageUrl) {
    final dataService = DataService();
    return FutureBuilder(
      future: dataService.fetchLatestGlobalData(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching data
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Data loaded successfully, build the horizontal list
          final List<DataPoint> dataPoints = snapshot.data!;

          return SizedBox(
            height: 120, // Set a fixed height for the horizontal list
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              itemCount: dataPoints.length,
              itemBuilder: (context, index) {
                final dataPoint = dataPoints[index];
                // You can build a more complex card widget here
                return _buildDataPointCard(context, dataPoint, imageUrl);
              },
            ),
          );
        } else {
          // Handle empty data state
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 50),
                SizedBox(height: 10),
                Text('No data available yet. Be the first to contribute!'),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDataPointCard(
    BuildContext context,
    DataPoint dataPoint,
    String imageUrl,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Coordinates: (${dataPoint.latitude.toStringAsFixed(2)}, ${dataPoint.longitude.toStringAsFixed(2)})',
            style: TextStyle(
              color: Color(0xFF101910),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (dataPoint.pressure != null) ...[
                Text(
                  'Pressure: ${dataPoint.pressure!.toStringAsFixed(1)} hPa',
                  style: TextStyle(color: Color(0xFF5C8E57), fontSize: 14),
                ),
              ],
              if (dataPoint.noiseLevel != null) ...[
                Text(
                  'Noise: ${dataPoint.noiseLevel?.toStringAsFixed(1)} dB',
                  style: TextStyle(color: Color(0xFF5C8E57), fontSize: 14),
                ),
              ],
              if (dataPoint.lightIntensity != null) ...[
                Text(
                  'Light: ${dataPoint.lightIntensity} lux',
                  style: TextStyle(color: Color(0xFF5C8E57), fontSize: 14),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// A placeholder for a stat card when there's no data available.
  static Widget _noDataStatCard({required String title}) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey, size: 24),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Text(
            'No Data',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
