// lib/services/sensor_manager.dart
import 'dart:async';
import 'dart:math'; // For log function
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For VoidCallback
import 'package:sensors_plus/sensors_plus.dart'; // For accelerometer, gyroscope (check for others)
import 'package:flutter_sound/flutter_sound.dart'; // For microphone
import 'package:geolocator/geolocator.dart'; // For GPS
import 'package:permission_handler/permission_handler.dart'; // For permissions
import '../models/sensor_readings.dart';
import 'package:light/light.dart';

class SensorManager {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<int>? _lightEvents;
  StreamSubscription<BarometerEvent>? _barometerEvent;
  StreamSubscription<Uint8List>?
  _audioStreamSubscription; // Subscription for audio stream

  // --- Streams for other sensors ---
  StreamSubscription<Position>? _positionSubscription;
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>.broadcast();
  // String? _tempAudioFilePath; // Variable to hold the temporary file path

  // --- Current State ---
  SensorReadings _currentReadings = SensorReadings.initial();
  SensorReadings get currentReadings => _currentReadings;

  VoidCallback? onReadingsUpdated;

  bool _isCapturing = false;
  bool get isCapturing => _isCapturing;

  // --- Error States ---
  final String _locationErrorMessage = '';
  final String _microphoneErrorMessage = '';
  String get locationErrorMessage => _locationErrorMessage;
  String get microphoneErrorMessage => _microphoneErrorMessage;

  SensorManager() {
    // Listen to the audio stream for noise calculation
    _audioStreamSubscription = _audioStreamController.stream.listen((buffer) {
      if (_isCapturing && buffer.isNotEmpty) {

        double amplitude = _calculateAmplitude(buffer);
        // Convert amplitude to dB (rough approximation)
        // Avoid log(0) by clamping to a small positive value
        double db = 20 * (log(amplitude.clamp(0.001, 1.0)) / ln10);
        _updateReadings(
          noiseLevel: db.clamp(-60, 0),
        ); // Clamp to reasonable range
      }
    });
  }

  // Helper method to calculate amplitude from audio buffer
  double _calculateAmplitude(Uint8List buffer) {
    if (buffer.isEmpty) return 0.0;
    int sum = 0;
    for (int i = 0; i < buffer.length; i++) {
      sum += buffer[i].abs();
    }
    // Normalize to 0.0 - 1.0. Clamp to prevent values > 1.0.
    return (sum / buffer.length / 255.0).clamp(0.0, 1.0);
  }

  // Update the current readings and notify listeners
  void _updateReadings({
    int? lightIntensity,
    double? noiseLevel,
    double? pressure,
    double? temperature,
    double? accX,
    double? accY,
    double? accZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    double? latitude,
    double? longitude,
    double? altitude,
    DateTime? timestamp,
  }) {
    _currentReadings = _currentReadings.copyWith(
      lightIntensity: lightIntensity,
      noiseLevel: noiseLevel,
      pressure: pressure,
      temperature: temperature,
      accX: accX,
      accY: accY,
      accZ: accZ,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      timestamp: timestamp ?? DateTime.now(),
    );
    onReadingsUpdated?.call(); // Notify UI/provider
  }

  /// Starts listening to configured sensors.
  Future<void> startCapturing() async {
    if (_isCapturing) return;

    // --- CRITICAL FIX: Get a writable temporary directory ---
    try {
      // Get the temporary directory provided by the OS
      // final tempDir = await getTemporaryDirectory();
      // Define a unique filename for the temporary recording
      // _tempAudioFilePath =
      //     '${tempDir.path}/ecosense_temp_recording.aac'; // Or .m4a
      // if (kDebugMode) {
      //   print(
      //     "DEBUG SensorManager: Using temporary audio file path: $_tempAudioFilePath",
      //   );
      // }
    } catch (e) {
      if (kDebugMode) {
        print(
          "ERROR SensorManager: Failed to get temporary directory for audio recording: $e",
        );
      }
      // Handle error appropriately - maybe disable noise level recording
      // _tempAudioFilePath = null; // Indicate failure to get path
      // You could show a snackbar or set an error state
      // return; // Or throw an error to prevent starting capture
    }

    // Request necessary permissions
    bool locationEnabled = await _requestLocationPermission();
    bool micEnabled = await _requestMicrophonePermission();
    // Sensors (ALS, Barometer, Accel, Gyro) usually don't require explicit permission beyond general sensor access.
    // But it's good practice to check.

    if (!locationEnabled || !micEnabled) {
      // Handle permission denial appropriately in your app
      // e.g., throw an exception or call an error callback
      if (kDebugMode) {
        print("SensorManager: Required permissions denied.");
      }
      return;
    }

    _isCapturing = true;
    // Reset readings to initial state with current timestamp
    _currentReadings = SensorReadings.initial();

    // --- Start Accelerometer ---
    try {
      _accelerometerSubscription = accelerometerEventStream().listen((
        AccelerometerEvent event,
      ) {
        if (_isCapturing) {
          if (kDebugMode) {
            print("Accel: ${event.x}, ${event.y}, ${event.z}");
          }
          _updateReadings(accX: event.x, accY: event.y, accZ: event.z);
        }
      });
    } catch (e) {
      // handle accelerometer erro
    }

    // --- Start Gyroscope ---
    try {
      _gyroscopeSubscription = gyroscopeEventStream().listen((
        GyroscopeEvent event,
      ) {
        if (_isCapturing) {
          // print("Gyro: ${event.x}, ${event.y}, ${event.z}");
          _updateReadings(gyroX: event.x, gyroY: event.y, gyroZ: event.z);
        }
      });
    } catch (e) {
      // handle gyroscope erro
    }

    // --- Start barometer ---
    try {
      _barometerEvent = barometerEventStream().listen((BarometerEvent event) {
        if (_isCapturing) {
          // print("Accel: ${event.x}, ${event.y}, ${event.z}");
          _updateReadings(pressure: event.pressure);
        }
      });
    } catch (e) {
      // handle barometer erro
    }

    // --- Attempt to Start Light Sensor (CHECK sensors_plus docs) ---

    try {
      _lightEvents = Light().lightSensorStream.listen((luxValue) {
        if (_isCapturing) {
          _updateReadings(lightIntensity: luxValue);
        }
      });
    } catch (e) {
      // handle light sensor erro
    }

    // --- Start Microphone for Noise ---
    // if (_tempAudioFilePath != null) {
      try {
        if (kDebugMode) {
          print("DEBUG SensorManager: Attempting to open audio recorder...");
        }
        await _audioRecorder.openRecorder();

        if (kDebugMode) {
          print("DEBUG SensorManager: Audio recorder session opened.");
        }
        await _audioRecorder.setSubscriptionDuration(
          const Duration(milliseconds: 100),
        );
        if (kDebugMode) {
          print("DEBUG SensorManager: Audio subscription duration set.");
        }

        await _audioRecorder.startRecorder(
          toStream: _audioStreamController
              .sink, // Specify the codec (AAC is common and efficient)
          codec: Codec.aacADTS, // Or Codec.opusOGG, Codec.mp3, etc.
          // Provide the path to the temporary file
          // toFile: _tempAudioFilePath,
        );

        if (kDebugMode) {
          print(
            "SensorManager: Microphone recorder started successfully (toStream).",
          );
        }
      } catch (e) {
        // Handle microphone error
        if (kDebugMode) {
          print("ERROR SensorManager: Failed to start microphone recorder: $e");
        }
        // Handle microphone error - maybe set _tempAudioFilePath to null and disable noise level
        // _tempAudioFilePath = null;
        // Optionally, show an error message to the user
      }
    // } else {
    //   if (kDebugMode) {
    //     print(
    //       "WARNING SensorManager: Skipping microphone recording due to missing temporary file path.",
    //     );
    //   }
    //   // Optionally, show a warning message to the user
    // }

    // --- Start GPS Location ---
    try {
      // Get initial location
      // Position initialPosition = await Geolocator.getCurrentPosition(
      //   locationSettings: LocationSettings(
      //     accuracy: LocationAccuracy.high,
      //     distanceFilter: 10, // Update every 10 meters
      //   ),
      // );
      // if (_isCapturing) {
      //   _updateReadings(
      //     latitude: initialPosition.latitude,
      //     longitude: initialPosition.longitude,
      //     altitude: initialPosition.altitude,
      //   );
      // }

      // Listen for continuous location updates
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
              timeLimit: const Duration(minutes: 10),
            ),
          ).listen(
            (Position position) {
              if (_isCapturing) {
                if (kDebugMode) {
                  print(
                    "GPS: Lat ${position.latitude}, Lng ${position.longitude}",
                  );
                }
                _updateReadings(
                  latitude: position.latitude,
                  longitude: position.longitude,
                  altitude: position.altitude,
                );
              }
            },
            onError: (error) {
              // --- IMPROVED ERROR HANDLING ---
              if (kDebugMode) {
                print("ERROR SensorManager: GPS Stream Error: $error");
              }
              // Check the type of error
              if (error is LocationServiceDisabledException) {
                if (kDebugMode) {
                  print(
                    "ERROR SensorManager: Location service was disabled during streaming.",
                  );
                }
                // Inform user to re-enable location services
                // onLocationError?.call('Location service was disabled. Please re-enable it.');
              } else if (error is PermissionDeniedException) {
                if (kDebugMode) {
                  print(
                    "ERROR SensorManager: Location permission was denied during streaming.",
                  );
                }
                // Inform user to grant permission
                // onLocationError?.call('Location permission was denied during streaming.');
              } else {
                if (kDebugMode) {
                  print(
                    "ERROR SensorManager: Unexpected GPS stream error: $error",
                  );
                }
                // onLocationError?.call('An unexpected error occurred with GPS: $error');
              }
              // --- END OF IMPROVED ERROR HANDLING ---
            },
          );
      if (kDebugMode) {
        print("SensorManager: GPS listener started.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro is : $e");
      }
    }
  }

  /// Stops listening to all sensors and cleans up resources.
  Future<void> stopCapturing() async {
    if (!_isCapturing) return;

    _isCapturing = false;

    // Cancel all subscriptions
    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    await _barometerEvent?.cancel();
    await _lightEvents?.cancel();
    await _positionSubscription?.cancel();
    await _audioStreamSubscription
        ?.cancel(); // Cancel audio stream subscription

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _barometerEvent = null;
    _lightEvents = null;
    _positionSubscription = null;
    _audioStreamSubscription = null; // Nullify audio stream subscription

    // Stop and close audio recorder
    try {
      if (_audioRecorder.isRecording) {
        await _audioRecorder.stopRecorder();
        if (kDebugMode) {
          print("DEBUG SensorManager: Audio recorder stopped.");
        }
      }
      await _audioRecorder.closeRecorder();
      if (kDebugMode) {
        print("DEBUG SensorManager: Audio recorder session closed.");
      }

      // --- OPTIONAL: Clean up the temporary audio file ---
      // if (_tempAudioFilePath != null) {
      //   final tempFile = File(_tempAudioFilePath!);
      //   if (await tempFile.exists()) {
      //     await tempFile.delete();
      //     if (kDebugMode) {
      //       print(
      //         "DEBUG SensorManager: Temporary audio file deleted: $_tempAudioFilePath",
      //       );
      //     }
      //   }
      //   _tempAudioFilePath = null; // Reset the path
      // }
    } catch (e) {
      // handle audio recording errors
      if (kDebugMode) {
        print(
          "ERROR SensorManager: Error stopping/closing microphone recorder: $e",
        );
      }
    }

    // Close the audio stream controller
    await _audioStreamController.close();
    if (kDebugMode) {
      print("SensorManager: All sensor capture stopped.");
    }
  }


Future<String> getCityFromOSM(double lat, double lon) async {
  // 1. Define the URL
  // IMPORTANT: Nominatim requires a User-Agent header to identify your app
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1'
  );

  try {
    final response = await http.get(url, headers: {
      'User-Agent': 'Ecosense/1.0 (formilackprincewill@gmail.com)' 
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.statusCode == 200 ? response.body : '');
      
      // 2. Extract city/town/village (OSM uses different tags based on size)
      Map<String, dynamic> address = data['address'];
      
      return address['city'] ?? 
             address['town'] ?? 
             address['village'] ?? 
             "Unknown Location";
    } else {
      return "Error: ${response.reasonPhrase}";
    }
  } catch (e) {
    return "Failed to connect: $e";
  }
}
  
  // --- Permission Handling ---

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // --- 1. Check if Location Services are enabled on the device ---
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print(
          'ERROR SensorManager: Location services are disabled on the device.',
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // --- 5. Permission granted (fine/coarse) ---
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (kDebugMode) {
        print(
          'DEBUG SensorManager: Location permission granted ($permission).',
        );
      }
      return true;
    }
    // --- 6. Fallback (shouldn't happen, but good to be safe) ---
    if (kDebugMode) {
      print(
        'WARNING SensorManager: Unexpected location permission state: $permission',
      );
    }
    return false;
  }

  Future<bool> _requestMicrophonePermission() async {
    // Use permission_handler for robust permission request
    var status = await Permission.microphone.request();
    bool granted = status == PermissionStatus.granted;
    if (granted) {
    } else {
      if (kDebugMode) {
        print("microphone permission granted");
      }
    }
    return granted;
  }

  // Ensure resources are cleaned up if the manager is disposed
  void dispose() async {
    await stopCapturing();
    // _audioRecorder should be closed in stopCapturing
  }
}
