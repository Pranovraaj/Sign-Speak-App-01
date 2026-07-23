// lib/core/services/ai_placeholder_services.dart

import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import '../utils/gesture_engine.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';
import 'js_helper_stub.dart'
    if (dart.library.js) 'js_helper_web.dart';

/// Interface for loading TensorFlow Lite models
abstract class IGestureModelLoader {
  Future<bool> loadModel(String modelPath);
  void close();
}

/// Interface for gesture recognition pipeline
abstract class IGestureRecognitionService {
  Future<void> initialize();
  Stream<RecognitionFrameResult> get gestureStream;
  void processCameraImage(CameraImage image);
  void processLandmarks(List<List<Landmark>> multiHandLandmarks);
  void clearBuffer();
  void dispose();
}

/// Mock TFLite model loader implementation
class MockGestureModelLoader implements IGestureModelLoader {
  String? _loadedModelPath;

  @override
  Future<bool> loadModel(String modelPath) async {
    print('TFLite Loader: Loading model from $modelPath...');
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate file IO latency
    _loadedModelPath = modelPath;
    print('TFLite Loader: Model loaded successfully ($modelPath)');
    return true;
  }

  @override
  void close() {
    print('TFLite Loader: Releasing TFLite interpreter for model $_loadedModelPath');
    _loadedModelPath = null;
  }
}

/// Default Gesture Recognition Service using our pure Dart Heuristic Engine
/// and supporting simulated gesture outputs for UI testing.
class HeuristicGestureRecognitionService implements IGestureRecognitionService {
  final GestureEngine _engine = GestureEngine();
  final _streamController = StreamController<RecognitionFrameResult>.broadcast();
  bool _isSimulating = false;
  Timer? _simulationTimer;

  HeuristicGestureRecognitionService() {
    _engine.setCustomGestures([]);
    
    // Wire up JavaScript MediaPipe callback receiver
    JsLandmarksConnector.registerCallback((String jsonCoords) {
      if (_isSimulating) return;
      try {
        final decoded = jsonDecode(jsonCoords) as List<dynamic>;
        if (decoded.isEmpty) {
          _streamController.add(
            RecognitionFrameResult(
              gesture: null,
              confidence: 0.0,
              state: 'Scanning Frames...',
              landmarks: [],
            ),
          );
          return;
        }

        List<List<Landmark>> multiHandLandmarks = [];
        for (var hand in decoded) {
          List<Landmark> landmarks = [];
          for (var lm in hand) {
            landmarks.add(Landmark(
              x: (lm['x'] as num).toDouble(),
              y: (lm['y'] as num).toDouble(),
              z: (lm['z'] as num).toDouble(),
            ));
          }
          multiHandLandmarks.add(landmarks);
        }

        processLandmarks(multiHandLandmarks);
      } catch (e) {
        print("HeuristicGestureRecognitionService: JS coordinates parse error: $e");
      }
    });
  }

  @override
  Future<void> initialize() async {
    print('GestureRecognitionService: Initializing pipeline...');
    clearBuffer();
  }

  Future<void> fetchCustomGestures(ApiClient apiClient) async {
    try {
      final response = await apiClient.get(AppConstants.endpointCustomGestures);
      if (response.statusCode == 200) {
        final data = response.data;
        List<CustomGesture> gestures = [];
        if (data is List) {
          gestures = data.map((e) => CustomGesture.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map && data.containsKey('data')) {
          final list = data['data'] as List;
          gestures = list.map((e) => CustomGesture.fromJson(e as Map<String, dynamic>)).toList();
        }
        _engine.setCustomGestures(gestures);
        print('GestureRecognitionService: Fetched \${gestures.length} custom gestures');
      }
    } catch (e) {
      print('GestureRecognitionService: Failed to fetch custom gestures - $e');
    }
  }

  @override
  Stream<RecognitionFrameResult> get gestureStream => _streamController.stream;

  @override
  void processCameraImage(CameraImage image) {
    // Placeholder: This is where TFLite tensor conversion takes place.
    // E.g. converting YUV420 to RGB / feeding pixel buffer to MediaPipe.
    // In our placeholder, since we are using Heuristics, we run landmarker simulations or wait for landmark inputs.
    if (_isSimulating) return;
    
    // We send a searching state feedback for camera frame streams by default if no landmarks are supplied
    _streamController.add(
      RecognitionFrameResult(
        gesture: null,
        confidence: 0.0,
        state: 'Scanning Frames...',
      ),
    );
  }

  @override
  void processLandmarks(List<List<Landmark>> multiHandLandmarks) {
    if (_isSimulating) return;

    final result = _engine.processFrame(multiHandLandmarks);
    _streamController.add(result);
  }

  @override
  void clearBuffer() {
    _engine.processFrame(null); // Clears the internal queue
    _streamController.add(
      RecognitionFrameResult(
        gesture: null,
        confidence: 0.0,
        state: 'Searching',
      ),
    );
  }

  /// Activates simulated gestures to help test the full app UI flows in Emulator/Simulators.
  void startSimulatedGestures(List<String> gestures, Duration interval) {
    stopSimulatedGestures();
    _isSimulating = true;
    int index = 0;

    _simulationTimer = Timer.periodic(interval, (timer) {
      if (gestures.isEmpty) return;
      final gesture = gestures[index % gestures.length];
      index++;

      _streamController.add(
        RecognitionFrameResult(
          gesture: gesture,
          confidence: 0.95,
          state: 'High Confidence',
        ),
      );
    });
  }

  void stopSimulatedGestures() {
    _isSimulating = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  void dispose() {
    stopSimulatedGestures();
    _streamController.close();
  }
}
