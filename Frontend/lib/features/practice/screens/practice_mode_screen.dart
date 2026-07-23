// lib/features/practice/screens/practice_mode_screen.dart

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/ai_placeholder_services.dart';
import '../../../core/services/tts_service.dart';
import '../../tutorial/providers/tutorial_provider.dart';
import '../../tutorial/screens/tutorial_screen.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/utils/gesture_engine.dart' as engine;
import '../../../core/widgets/hand_skeleton_painter.dart';

class PracticeModeScreen extends ConsumerStatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  ConsumerState<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends ConsumerState<PracticeModeScreen> {
  final CameraService _cameraService = CameraService();
  final TextToSpeechService _tts = TextToSpeechService();
  final HeuristicGestureRecognitionService _recognitionService = HeuristicGestureRecognitionService();
  StreamSubscription? _gestureSubscription;

  bool _isCameraInitialized = false;
  bool _cameraPermissionError = false;
  String _statusMessage = 'Align your hand in the preview...';
  double _confidence = 0.0;
  bool _practiceSuccess = false;
  List<List<engine.Landmark>>? _currentLandmarks;

  // Track consecutive successful frames
  int _consecutiveMatchCount = 0;
  static const int requiredConsecutiveFrames = 5;

  @override
  void initState() {
    super.initState();
    _startPracticeFlow();
  }

  Future<void> _startPracticeFlow() async {
    // 1. Initialize Camera
    try {
      await _cameraService.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
      
      // Fetch user custom gestures
      await _recognitionService.fetchCustomGestures(ref.read(apiServiceProvider));
      
      // Start streaming frames to our recognition engine
      await _cameraService.startImageStream((CameraImage img) {
        _recognitionService.processCameraImage(img);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraPermissionError = true;
        });
      }
      print('Camera initialization failed: $e');
    }

    // 2. Bind Gesture Stream
    final targetGesture = ref.read(selectedPracticeGestureProvider);
    if (targetGesture == null) return;

    _tts.speak('Practice mode: Please sign ${targetGesture.name}');

    _recognitionService.clearBuffer();
    _gestureSubscription = _recognitionService.gestureStream.listen((res) {
      if (!mounted || _practiceSuccess) return;

      setState(() {
        _confidence = res.confidence;
        _statusMessage = res.state;
        _currentLandmarks = res.landmarks;
      });

      // Check if gesture matches target
      if (res.gesture != null && res.gesture!.toLowerCase() == targetGesture.id.toLowerCase() && res.confidence > 0.5) {
        _consecutiveMatchCount++;
        if (_consecutiveMatchCount >= requiredConsecutiveFrames) {
          _handlePracticeSuccess();
        }
      } else {
        _consecutiveMatchCount = 0;
      }
    });
  }

  void _handlePracticeSuccess() {
    setState(() {
      _practiceSuccess = true;
      _statusMessage = 'Success! Correct sign matched.';
    });

    _tts.speak('Excellent work! Sign matched.');

    // Save completion state to Riverpod and cache
    final targetGesture = ref.read(selectedPracticeGestureProvider);
    if (targetGesture != null) {
      ref.read(progressProvider.notifier).complete(targetGesture.id);
    }
  }

  Future<void> _stopFlow() async {
    _gestureSubscription?.cancel();
    _recognitionService.dispose();
    await _cameraService.stopImageStream();
    await _cameraService.dispose();
  }

  @override
  void dispose() {
    _stopFlow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gesture = ref.watch(selectedPracticeGestureProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (gesture == null) {
      return const Scaffold(body: Center(child: Text('No practice gesture selected')));
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppTheme.darkSlate),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Practice Console',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.darkSlate,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          
          final children = [
            // Split 1: Gesture details card
            Expanded(
              flex: isTablet ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildGestureGuideCard(context, gesture),
              ),
            ),

            // Split 2: Camera View Overlay
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildCameraContainer(context),
              ),
            ),
          ];

          return isTablet 
              ? Row(children: children) 
              : Column(children: children);
        },
      ),
    );
  }

  Widget _buildGestureGuideCard(BuildContext context, gesture) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    gesture.name,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    gesture.category.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                gesture.image,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey.shade100, height: 130),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              gesture.description,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraContainer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _practiceSuccess 
              ? Colors.green 
              : (_confidence > 0 ? AppTheme.neonPurple : Colors.grey.withOpacity(0.3)),
          width: 2.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Camera Preview / Loading State
          if (_isCameraInitialized && _cameraService.controller != null)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159), // Mirror camera preview
              child: CameraPreview(_cameraService.controller!),
            )
          else if (_cameraPermissionError)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off_rounded, color: Colors.redAccent, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Camera Permission Denied',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Please enable camera permissions in app settings to practice live tracking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.neonCyan),
                SizedBox(height: 12),
                Text('Connecting Camera Feed...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

          // Draw Hand skeleton overlay if landmarks exist
          if (_currentLandmarks != null && !_practiceSuccess)
            CustomPaint(
              painter: HandSkeletonPainter(_currentLandmarks),
            ),

          // Success Congratulatory Overlay
          if (_practiceSuccess)
            Container(
              color: Colors.black87,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    'GOAL ACHIEVED!',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign vocabulary marked as learned.',
                    style: TextStyle(color: Color(0xBDFFFFFF), fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CONTINUE COURSE'),
                  ),
                ],
              ),
            ),

          // Real-time engine status banner
          if (!_practiceSuccess)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    if (_confidence > 0)
                      Text(
                        '${(_confidence * 100).toStringAsFixed(0)}% Match',
                        style: const TextStyle(
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Dev simulator shortcut for emulator compatibility
          if (!_practiceSuccess)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: _handlePracticeSuccess,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bug_report_rounded, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text('Simulate Success', style: TextStyle(color: Colors.amber, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
