import 'package:ecosense/providers/auth_provider.dart';
import 'package:ecosense/providers/sensor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LiveSensorReadingsPage extends StatelessWidget {
  const LiveSensorReadingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the SensorProvider
    final sensorProvider = context.watch<SensorProvider>();
    final authProvider = context.watch<AuthProvider>(); // u could also use provider.of(context)

    void stopCapturing() async {
      sensorProvider.stopCapturing();

      // Ensure user is logged in
      if (!authProvider.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to submit data.')),
        );
        // Optionally navigate to login screen
        return;
      }
      // Get the latest readings (should be populated after stopCapturing)
      final readingsToSubmit = sensorProvider.currentReadings;
      final userId = authProvider.user?.id; // Get the Supabase User ID

      // Basic validation: Check if we have location and user ID
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User authentication error. Cannot submit data.'),
          ),
        );
        return;
      }
      if ((readingsToSubmit.latitude.abs() < 1e-6) &&
          (readingsToSubmit.longitude.abs() < 1e-6)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not available. Cannot submit data.'),
          ),
        );
        return;
      }

      // Note: You might want more robust checks for other sensor values

      // Show loading indicator
      final snackBar = SnackBar(
        content: const Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 10),
            Text('Submitting data and awarding points...'),
          ],
        ),
        duration: const Duration(
          seconds: 15,
        ), // Adjust duration or make it indefinite
        // Optionally add an action to cancel/close if needed
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      try {
        // --- CALL THE SUBMISSION METHOD ---
        // This method will handle writing to Firestore AND awarding points
        final result = await sensorProvider.submitDataAndAwardPoints(
          userId: userId, // Pass the user ID
          // Pass the readings from sensorProvider.currentReadings
          latitude: readingsToSubmit.latitude,
          longitude: readingsToSubmit.longitude,
          // Use appropriate getters based on your SensorReadings model
          // The model we built earlier had accX, gyroX, etc., but API expects air_quality, noise_level, light_intensity
          // You might need to map or derive these values.
          // For now, assuming your SensorReadings model has these specific fields or you derive them:
          pressure: readingsToSubmit.pressure,
          noiseLevel: readingsToSubmit.noiseLevel,
          lightIntensity: readingsToSubmit.lightIntensity?.round(),
          // If you have specific AQ sensor data, use that instead of pressure
          timestamp: readingsToSubmit.timestamp,
        );

        // Remove loading snackbar
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (result['success'] == true) {
          // Handle success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ??
                    'Data submitted successfully! Points awarded!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Force global Provider refresh to sync Dashboard metrics & UI points
          authProvider.refreshUserProfileAndHistory();

          // Navigate back to Home Dashboard or another screen
          Navigator.of(
            context,
          ).pop(); // Or use Navigator.pushNamedAndRemoveUntil(...)
        } else {
          // Handle API error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to submit data.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Remove loading snackbar
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Handle network or unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // --- END OF SUBMIT LOGIC ---
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Live Sensor Readings',
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
      body: ListView(
        children: [
          // Air Quality Index Card
          _buildSensorCard(
            context: context,
            image: 'images/pressure.png',
            title: 'Air Pressure',
            value:
                sensorProvider.currentReadings.pressure?.toStringAsFixed(1) ??
                'N/A',
            unit: 'hPa',
            grade: 'Good',
            color: _getPressureColor(
              sensorProvider.currentReadings.pressure,
            ), //Color(0xFF5C8E57),
          ),

          // Noise Level Card
          _buildSensorCard(
            context: context,
            image: 'images/sound.png',
            title: 'Noise Level',
            value:
                sensorProvider.currentReadings.noiseLevel?.toStringAsFixed(1) ??
                'N/A',
            unit: 'dB',
            grade: 'Moderate',
            color: _getNoiseColor(
              sensorProvider.currentReadings.noiseLevel,
            ), //Color(0xFF5C8E57),
          ),

          // Light Intensity Card
          _buildSensorCard(
            context: context,
            image: 'images/light.png',
            title: 'Light Intensity',
            value:
                sensorProvider.currentReadings.lightIntensity?.toStringAsFixed(
                  0,
                ) ??
                'N/A',
            unit: 'lux',
            grade: 'Bright',
            color: _getLightColor(
              sensorProvider.currentReadings.lightIntensity,
            ), //Color(0xFF5C8E57),
          ),
        ],
      ),

      // Bottom Section
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location Section
          Container(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Location',
                style: TextStyle(
                  color: Color(0xFF101910),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${sensorProvider.currentReadings.latitude.toStringAsFixed(4)}, ${sensorProvider.currentReadings.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: Color(0xFF101910), fontSize: 16),
            ),
          ),
          if (sensorProvider.currentReadings.altitude != null) ...[
            Container(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Altitude',
                  style: TextStyle(
                    color: Color(0xFF101910),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${sensorProvider.currentReadings.altitude!.toStringAsFixed(1)} m',
                style: TextStyle(color: Color(0xFF101910), fontSize: 16),
              ),
            ),
          ],

          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (!sensorProvider.isCapturing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        sensorProvider.startCapturing();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF298321),
                        foregroundColor: Color(0xFFF9FBF9),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Start Capture',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 12),
                if (sensorProvider.isCapturing)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: stopCapturing,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFEAF1E9),
                        foregroundColor: Color(0xFF101910),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide.none,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Stop & Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Spacer
          Container(height: 20, color: Color(0xFFF9FBF9)),

          // //bottom nav
          // BottomNav(),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required BuildContext context,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required String image,
    required String grade,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Container(
              height: 200, // aspect-video = 16:9 ratio
              decoration: BoxDecoration(
                image: DecorationImage(
                  // image: NetworkImage(
                  //   image, // Placeholder image
                  // ),
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFF101910),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$value $unit',
                            style: TextStyle(color: color, fontSize: 16),
                          ),
                          Text(
                            grade,
                            style: TextStyle(color: color, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPressureColor(double? pressure) {
    // Standard atmospheric pressure is ~1013 hPa
    if (pressure == null) return Colors.grey;
    if (pressure < 1000) return Colors.blue; // Low pressure, potentially stormy
    if (pressure > 1025) return Colors.orange; // High pressure, potentially dry
    return Colors.green; // Normal range
  }

  Color _getNoiseColor(double? noise) {
    if (noise == null) return Colors.grey;
    if (noise < 40) return Colors.green; // Quiet
    if (noise < 60) return Colors.yellow; // Normal Conversation
    if (noise < 80) return Colors.orange; // Busy Traffic
    return Colors.red; // Loud / Potentially harmful
  }

  Color _getLightColor(int? light) {
    if (light == null) return Colors.grey;
    if (light < 50) return Colors.blueGrey; // Dark
    if (light < 200) return Colors.blue; // Dim
    if (light < 1000) return Colors.green; // Normal Indoor
    if (light < 5000) return Colors.yellow; // Bright Indoor
    return Colors.orange; // Very Bright / Outdoor Sunlight
  }
}
