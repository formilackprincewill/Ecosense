// lib/screens/global_map_view_screen.dart
import 'package:ecosense/screens/nav_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart'; // For clustering
import '../models/data_point.dart';
import '../services/data_service.dart';

class GlobalMapViewScreen extends StatefulWidget {
  const GlobalMapViewScreen({super.key});

  @override
  State<GlobalMapViewScreen> createState() => _GlobalMapViewScreenState();
}

class _GlobalMapViewScreenState extends State<GlobalMapViewScreen> {
  late MapController _mapController;
  List<DataPoint> _dataPoints = [];
  bool _isLoading = true;
  String _errorMessage = '';
  // Marker clustering
  MarkerClusterLayerOptions _clusterOptions = MarkerClusterLayerOptions(
    builder: (context, markers) {
      return Text('');
    },
  );

  // Initial map position (centered, zoomed out)
  static final LatLng _initialCenter = LatLng(
    0.0,
    0.0,
  ); // Roughly center on equator

  // Search and Filter State
  final TextEditingController _searchController = TextEditingController();
  String _selectedParameter =
      'all'; // 'all', 'air_quality', 'noise_level', 'light_intensity'
  DateTimeRange? _selectedDateRange;
  double _selectedRadiusKm = 10.0; // Default radius in km

  static const double _initialZoom = 2.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadMapData(); // Load data when the screen initializes
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches data points and updates the map markers.
  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch latest data points (adjust limit as needed, consider pagination for large datasets)
      List<DataPoint> fetchedPoints = await DataService().fetchLatestGlobalData(
        limit: 200,
      );

      setState(() {
        _dataPoints = fetchedPoints;
        _isLoading = false;
        // Update cluster options which depend on _dataPoints
        _updateClusterOptions();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load map data. Please try again.';
        // _dataPoints.clear();
        // _updateClusterOptions(); // Update clusters even on error (will be empty)
      });
    }
  }

  /// Updates the MarkerClusterLayerOptions based on the current _dataPoints.
  void _updateClusterOptions() {
    // Create markers from data points
    List<Marker> markers = _dataPoints.map((dp) {
      _getMarkerColor(dp);
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(dp.latitude, dp.longitude),
        child: GestureDetector(
          onTap: () => _showPinDetailsPopup(dp),
          child: Container(
            decoration: BoxDecoration(
              color: _getMarkerColor(dp), //markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getMarkerValue(dp), //dp.airQuality?.toString() ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    setState(() {
      // Configure clustering options
      _clusterOptions = MarkerClusterLayerOptions(
        maxClusterRadius:
            120, // Radius in pixels within which markers will be clustered
        size: const Size(40, 40), // Size of the cluster marker
        // anchor: AnchorPos.align(AnchorAlign.center),
        // fitBoundsOptions: const FitBoundsOptions(
        // padding: EdgeInsets.all(12),
        // ),
        markers: markers, // Pass the list of markers
        polygonOptions: const PolygonOptions(
          borderColor: Colors.transparent,
          color: Colors.black12,
        ),
        builder: (context, markers) {
          // Customize the appearance of the cluster marker
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: _getClusterColor(markers.length), //Colors.blue,
            ),
            child: Center(
              child: Text(
                markers.length
                    .toString(), // Show the count of markers in the cluster
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  /// Determines marker color based on Air Quality Index (AQI) or proxy value.
  Color _getMarkerColor(DataPoint dp) {
    if (_selectedParameter == 'pressure' && dp.pressure != null) {
      return _getPressureColor(dp.pressure!);
    } else if (_selectedParameter == 'noise_level' && dp.noiseLevel != null) {
      return _getNoiseColor(dp.noiseLevel!);
    } // Good
    else if (_selectedParameter == 'light_intensity' &&
        dp.lightIntensity != null) {
      _getLightColor(dp.lightIntensity!);
    } // Moderate

    return Colors.grey;
  }

  static Color _getPressureColor(double? pressure) {
    if (pressure == null) return Colors.grey;
    if (pressure < 1000) return Colors.blue;
    if (pressure < 1013) return Colors.green;
    if (pressure < 1025) return Colors.yellow;
    return Colors.orange;
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

  String _getMarkerValue(DataPoint dp) {
    if (_selectedParameter == 'pressure' && dp.pressure != null) {
      return dp.pressure!.toStringAsFixed(1);
    } else if (_selectedParameter == 'noise_level' && dp.noiseLevel != null) {
      return dp.noiseLevel!.toStringAsFixed(1);
    } else if (_selectedParameter == 'light_intensity' &&
        dp.lightIntensity != null) {
      return dp.lightIntensity.toString();
    } else {
      // Show a generic indicator or first available value
      if (dp.pressure != null) return dp.pressure!.toStringAsFixed(1);
      if (dp.noiseLevel != null) return dp.noiseLevel!.toStringAsFixed(1);
      if (dp.lightIntensity != null) return dp.lightIntensity.toString();
      return '?';
    }
  }

  Color _getClusterColor(int count) {
    // Simple color based on cluster size
    if (count > 50) return Colors.red;
    if (count > 20) return Colors.orange;
    if (count > 5) return Colors.yellow;
    return Colors.green;
  }

  // --- Search Functionality ---
  Future<void> _performSearch() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      Location location = locations.first;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        if (mounted) {
          Placemark place = placemarks.first;
          _mapController.move(
            LatLng(location.latitude, location.longitude),
            12.0,
          ); // Zoom in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Found location: ${place.locality ?? place.subAdministrativeArea ?? ''}, ${place.country ?? ''}'
                    .trim(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Location not found.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search failed. Please try again.')),
        );
      }
    }
  }
  // --- End Search ---

  // --- Filter Bottom Sheet ---
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage state inside the sheet
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    16.0, // Adjust for keyboard
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Data',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Parameter:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedParameter,
                    items:
                        <String>[
                          'all',
                          'air_quality',
                          'noise_level',
                          'light_intensity',
                        ].map<DropdownMenuItem<String>>((String value) {
                          String displayText = value
                              .split('_')
                              .map(
                                (word) =>
                                    word[0].toUpperCase() + word.substring(1),
                              )
                              .join(' ');
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(displayText),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          // Update state within the bottom sheet
                          _selectedParameter = newValue;
                        });
                        Navigator.pop(context); // Close sheet after selection
                        _applyFilters(); // Apply the new filter
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Date Range:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: _selectedDateRange,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Theme.of(
                                  context,
                                ).primaryColor, // Use app's primary color
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          // Update state within the bottom sheet
                          _selectedDateRange = picked;
                        });
                        if (!context.mounted) return;
                        Navigator.pop(context); // Close sheet
                        _applyFilters(); // Apply the new filter
                      }
                    },
                    child: Text(
                      _selectedDateRange == null
                          ? 'Select Date Range'
                          : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Radius (km):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _selectedRadiusKm.clamp(1.0, 100.0),
                    min: 1.0,
                    max: 100.0,
                    divisions: 99,
                    label: _selectedRadiusKm.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        // Update state within the bottom sheet
                        _selectedRadiusKm = value;
                      });
                    },
                  ),
                  Text('${_selectedRadiusKm.round()} km'),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Reset filters
                          setState(() {
                            _selectedParameter = 'all';
                            _selectedDateRange = null;
                            _selectedRadiusKm = 10.0;
                          });
                          Navigator.pop(context); // Close sheet
                          _applyFilters(); // Apply reset filters
                        },
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close sheet
                          _applyFilters(); // Apply the selected filters
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _applyFilters() async {
    // This is where you would re-fetch data based on the selected filters
    // For now, we'll just reload all data and rely on UI filtering (marker color/value)
    // A more efficient approach would involve querying Firestore with filters
    await _loadMapData(); // Reload data (could be optimized with actual filtering)
    // Update cluster options to reflect new filters (marker colors/values)
    _updateClusterOptions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filters applied (UI only for now).')),
      );
    }
  }
  // --- End Filter Bottom Sheet ---

  // --- Pin Details Popup ---
  void _showPinDetailsPopup(DataPoint dataPoint) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Point Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Contributor: ${dataPoint.submittedByName}'),
              Text(
                'Time: ${dataPoint.timestamp.toLocal()}',
              ), // Format as needed
              if (dataPoint.pressure != null)
                Text('Pressure: ${dataPoint.pressure!.toStringAsFixed(1)} hPa'),
              if (dataPoint.noiseLevel != null)
                Text('Noise: ${dataPoint.noiseLevel?.toStringAsFixed(1)} dB'),
              if (dataPoint.lightIntensity != null)
                Text('Light: ${dataPoint.lightIntensity} lux'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Implement share logic (e.g., using share_plus)
                      Navigator.pop(context);
                    },
                    child: const Text('Share'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Reloads data, useful for pull-to-refresh or manual refresh.
  Future<void> _refreshData() async {
    await _loadMapData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Global Environmental Map',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF101910)),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const NavWrapper())),
        ),
        actions: [
          // IconButton(icon: const Icon(Icons.filter_list), onPressed: _refreshData),
          // Add filter button if needed
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- Search Bar ---
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search location...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) =>
                    _performSearch(), // Trigger search on Enter/Submit
              ),
            ),
          ),

          // --- Map ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              // Add interactivity options as needed
              //onTap: _handleMapTap, // Example for handling map taps
              //onPositionChanged: _onPositionChanged, // For loading data based on map movement (advanced)
            ),
            children: [
              // --- Tile Layer (OpenStreetMap) ---
              TileLayer(
                // Default OSM tile source
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const [
                  'a',
                  'b',
                  'c',
                ], // Subdomains for load balancing
                userAgentPackageName:
                    'com.example.ecosense', // Replace with your app's package name
                // Add attribution for OSM (important!)
              ),
              // --- Attribution Widget ---
              // const AttributionWidget.defaultWidget(
              //   source: 'OpenStreetMap contributors',
              //   onSourceTapped: null, // Or link to OSM website
              // ),
              // --- Marker Cluster Layer ---
              // This layer will display markers and handle clustering automatically
              MarkerClusterLayerWidget(options: _clusterOptions),
            ],
          ),

          const Positioned(
            right: 5.0,
            bottom: 5.0,
            child: Text(
              'OpenStreetMap contributors',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
                backgroundColor: Colors.white70,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          // Add zoom controls
          Positioned(
            right: 10,
            bottom: 100, // Adjust based on UI
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1.0,
                    );
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1.0,
                    );
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refreshData,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // Optional: Add a FAB for location or other actions
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _goToCurrentLocation, // Implement this method
      //   child: const Icon(Icons.my_location),
      // ),
    );
  }
}
