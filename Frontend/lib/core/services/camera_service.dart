// lib/core/services/camera_service.dart

import 'dart:convert';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras found on the device');
      }

      // Initialize with the front camera by default (self-facing for signs)
      final frontCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      print('CameraService Initialization Error: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  Future<void> startImageStream(void Function(CameraImage image) onFrame) async {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isStreamingImages) return;

    await _controller!.startImageStream(onFrame);
  }

  Future<void> stopImageStream() async {
    if (_controller == null || !_isInitialized) return;
    if (!_controller!.value.isStreamingImages) return;

    await _controller!.stopImageStream();
  }

  // Captures current frame and compresses it to a simulated base64 string or file path
  // Since we don't want to block UI threads, we can mock or use controller's takePicture method.
  Future<String> captureBase64Frame() async {
    if (_controller == null || !_isInitialized) return '';
    try {
      // In a real application, we can use _controller!.takePicture()
      // For fast real-time feedback without blocking, we can use a mock placeholder base64 string or capture a light picture.
      // We will capture an actual image file and encode it to base64 for history logging.
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Failed to capture frame: $e');
      return ''; // Return empty string on failure
    }
  }
}
