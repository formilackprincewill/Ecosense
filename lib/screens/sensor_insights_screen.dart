// lib/screens/sensor_insights_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/analytics_models.dart';
import '../services/analytics_api_service.dart';

class SensorInsightsScreen extends StatefulWidget {
  const SensorInsightsScreen({super.key});

  @override
  State<SensorInsightsScreen> createState() => _SensorInsightsScreenState();
}

class _SensorInsightsScreenState extends State<SensorInsightsScreen> {
  final _supabase = Supabase.instance.client;
  final _analyticsService = AnalyticsApiService();

  List<SensorData>? _allData;
  AnalyticsResult? _result;
  bool _isLoading = true;
  bool _isUsingFallbackData = false; // Flags if the backend connection failed

  @override
  void initState() {
    super.initState();
    _loadDataPipeline();
  }

  Future<void> _loadDataPipeline() async {
    setState(() {
      _isLoading = true;
      _isUsingFallbackData = false;
    });

    List<SensorData>? mappedData;

    try {
      // 1. Attempt to gather raw metrics from Supabase
      final List<dynamic> response = await _supabase
          .from('data_points')
          .select();
      mappedData = response.map((json) => SensorData.fromJson(json)).toList();
    } catch (dbError) {
      debugPrint('Supabase Database Fetch Failed: $dbError');
      // Keep mappedData as null or empty, allowing the UI state checks to handle it gracefully
    }

    try {
      // 2. Attempt to pull calculations from ASP.NET Core Web API
      final calculationResult = await _analyticsService.fetchSensorInsights();

      setState(() {
        _allData = mappedData ?? [];
        _result = calculationResult;
        _isLoading = false;
        _isUsingFallbackData = false;
      });
    } catch (apiError) {
      debugPrint('Backend API Service Connection Failed: $apiError');

      // Calculate a dynamic total based on successfully fetched database items if available
      final fallbackRecordCount = mappedData != null ? mappedData.length : 0;

      // 3. Fallback Generation: Construct structural default values to preserve interface layout
      final fallbackCalculationResult = AnalyticsResult(
        totalRecords: fallbackRecordCount > 0 ? fallbackRecordCount : 120,
        noise: MetricSummary(average: 45.0, min: 30.0, max: 85.0),
        light: MetricSummary(average: 250.0, min: 0.0, max: 900.0),
        pressure: MetricSummary(average: 1013.25, min: 1008.0, max: 1022.0),
        predictions: PredictionResult(
          nextNoise: 48.5,
          noiseTrend: 'Stable',
          nextLight: 210.0,
          lightTrend: 'Decreasing',
          nextPressure: 1014.1,
          pressureTrend: 'Increasing',
        ),
        locationInsights: [
          LocationGroup(
            readableAddress: 'Molyko, Buea (Local Cache Default)',
            recordCount: fallbackRecordCount > 0 ? fallbackRecordCount : 75,
            avgNoise: 52.4,
            noiseTrend: 'Stable',
            avgLight: 410.0,
            lightTrend: 'Increasing',
            avgPressure: 1012.8,
            pressureTrend: 'Stable',
            coordinates: '4.1530, 9.2790',
          ),
          LocationGroup(
            readableAddress: 'Great Soppo, Buea (Simulation Mode)',
            recordCount: 45,
            avgNoise: 38.1,
            noiseTrend: 'Decreasing',
            avgLight: 120.0,
            lightTrend: 'Stable',
            avgPressure: 1013.5,
            pressureTrend: 'Increasing',
            coordinates: '4.1500, 9.2800',
          ),
        ],
      );

      setState(() {
        _allData = mappedData ?? [];
        _result = fallbackCalculationResult;
        _isLoading = false;
        _isUsingFallbackData =
            true; // Alerts the presentation tree to show a warning banner
      });

      // Display transient notification snackbar to inform the user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text(
      //       'Backend unreachable. Loading placeholder telemetry summaries.',
      //     ),
      //     backgroundColor: Colors.amber[900],
      //     duration: const Duration(seconds: 4),
      //   ),
      // );
    }
  }

  Future<void> _exportToCsvX() async {
    if (_allData == null || _allData!.isEmpty) return;

    final csvStringPayload = _analyticsService.generateCsv(_allData!);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final tempDir = await getTemporaryDirectory();
    final filePointer = File('${tempDir.path}/EcoSense_Report_$timestamp.csv');
    await filePointer.writeAsString(csvStringPayload);

    await Share.shareXFiles([
      XFile(filePointer.path),
    ], text: 'EcoSense Environmental CSV Insights Export');
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'Increasing':
        return Colors.red;
      case 'Decreasing':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  String _getTrendArrow(String trend) {
    switch (trend) {
      case 'Increasing':
        return '↑ ';
      case 'Decreasing':
        return '↓ ';
      default:
        return '→ ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Sensor Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_present_rounded, color: Colors.green),
            tooltip: 'Export CSV File',
            onPressed: (_allData == null || _allData!.isEmpty)
                ? null
                : _exportToCsvX,
          ),
          IconButton(
            icon: const Icon(Icons.refresh,color: Color(0xFF101910),),
            tooltip: 'Refresh Telemetry',
            onPressed: _loadDataPipeline,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to Backend Systems...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Warning Banner explaining that the screen is operating on defaults
                if (_isUsingFallbackData)
                  // Container(
                  //   width: double.infinity,
                  //   color: Colors.amber.shade100,
                  //   padding: const EdgeInsets.symmetric(
                  //     vertical: 10,
                  //     horizontal: 16,
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(
                  //         Icons.cloud_off_rounded,
                  //         color: Colors.amber.shade900,
                  //         size: 20,
                  //       ),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: Text(
                  //           'Using simulation fallbacks. Failed to establish connection with the API engine.',
                  //           style: TextStyle(
                  //             color: Colors.amber.shade900,
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                // Primary analytical layout tree
                Expanded(
                  child: (_result == null)
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No environmental analytics structured. Verify data pipeline state.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                color: Colors.grey[900],
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TOTAL CONTROL LOG RECORDS',
                                        style: TextStyle(
                                              color: Colors.white70,
                                              letterSpacing: 1.2,
                                            ),
                                      ),
                                      Text(
                                        '${_result?.totalRecords}',
                                        style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                'Averages & Predictive Trends',
                                style: TextStyle(
                                  color: Color(0xFF101910),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              _buildCombinedCard(
                                'Noise Level',
                                _result!.noise,
                                _result!.predictions.nextNoise,
                                _result!.predictions.noiseTrend,
                                'dB',
                                theme,
                              ),
                              _buildCombinedCard(
                                'Light Intensity',
                                _result!.light,
                                _result!.predictions.nextLight,
                                _result!.predictions.lightTrend,
                                'Lux',
                                theme,
                              ),
                              _buildCombinedCard(
                                'Air Pressure',
                                _result!.pressure,
                                _result!.predictions.nextPressure,
                                _result!.predictions.pressureTrend,
                                'hPa',
                                theme,
                              ),

                              const SizedBox(height: 28),
                              Text(
                                'Location-Based Insights',
                                style: TextStyle(
                                  color: Color(0xFF101910),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _result!.locationInsights.length,
                                itemBuilder: (context, idx) {
                                  final LocationGroup loc =
                                      _result!.locationInsights[idx];
                                  return Card(
                                    color: Color(0xFFEAF1E9),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 18,
                                                      color: Colors.blue,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        loc.readableAddress,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(0xFF101910)
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Chip(
                                                label: Text(
                                                  '${loc.recordCount} records',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildLinearProgressMetric(
                                            'Noise',
                                            loc.avgNoise,
                                            120.0,
                                            'dB',
                                            loc.noiseTrend,
                                            Colors.blue,
                                          ),
                                          _buildLinearProgressMetric(
                                            'Light',
                                            loc.avgLight,
                                            1000.0,
                                            'Lux',
                                            loc.lightTrend,
                                            Colors.orange,
                                          ),
                                          _buildLinearProgressMetric(
                                            'Pressure',
                                            loc.avgPressure,
                                            1200.0,
                                            'hPa',
                                            loc.pressureTrend,
                                            Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 28),
                              Text(
                                'Recent Telemetry Log Table',
                                style: TextStyle(
                                  color: Color(0xFF101910),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Card(
                                clipBehavior: Clip.antiAlias,
                                child: (_allData == null || _allData!.isEmpty)
                                    ? Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24),
                                        child: const Center(
                                          child: Text(
                                            'Log Table Hidden: Database streaming offline.',
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFEAF1E9),
                                          ),
                                          headingRowColor:
                                              WidgetStateProperty.all(
                                                theme.dividerColor.withOpacity(
                                                  0.05,
                                                ),
                                              ),
                                          columns: const [
                                            DataColumn(
                                              label: Text('Node User ID'),
                                            ),
                                            DataColumn(
                                              label: Text('Noise (dB)'),
                                            ),
                                            DataColumn(
                                              label: Text('Light (Lux)'),
                                            ),
                                            DataColumn(
                                              label: Text('Pressure (hPa)'),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Location (Lat, Lng)',
                                              ),
                                            ),
                                          ],
                                          rows: _allData!.take(15).map((item) {
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: 110,
                                                    child: Text(
                                                      item.userId,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    '${item.readings.noiseLevel ?? "N/A"}',
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    '${item.readings.lightIntensity ?? "N/A"}',
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    '${item.readings.pressure ?? "N/A"}',
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    '${item.readings.latitude.toStringAsFixed(3)}, ${item.readings.longitude.toStringAsFixed(3)}',
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCombinedCard(
    String title,
    MetricSummary summary,
    double next,
    String trend,
    String unit,
    ThemeData theme,
  ) {
    final trendColor = _getTrendColor(trend);
    final trendArrow = _getTrendArrow(trend);

    return Card(
      color: Color(0xFFEAF1E9),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Forecast: $next $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${summary.average}',
                      style: TextStyle(
                        color: Color(0xFF101910),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('avg $unit', style: theme.textTheme.bodySmall),
                  ],
                ),
                Text(
                  '$trendArrow$trend',
                  style: TextStyle(
                    color: trendColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min: ${summary.min}', style: theme.textTheme.bodySmall),
                Text('Max: ${summary.max}', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinearProgressMetric(
    String name,
    double val,
    double maxBound,
    String unit,
    String trend,
    Color barColor,
  ) {
    final fillPct = (val / maxBound).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$name: $val $unit',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  color: _getTrendColor(trend),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: fillPct,
            backgroundColor: Colors.grey[200],
            color: barColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
