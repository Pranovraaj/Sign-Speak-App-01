// lib/features/live_translation/screens/live_translation_screen.dart

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/ai_placeholder_services.dart';
import '../../../core/services/tts_service.dart';
import '../../history/providers/history_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/utils/gesture_engine.dart' as engine;
import '../../../core/widgets/hand_skeleton_painter.dart';

// Local states for the translation console
final autoVocalizeProvider = StateProvider<bool>((ref) => true);

class LiveTranslationScreen extends ConsumerStatefulWidget {
  const LiveTranslationScreen({super.key});

  @override
  ConsumerState<LiveTranslationScreen> createState() => _LiveTranslationScreenState();
}

class _LiveTranslationScreenState extends ConsumerState<LiveTranslationScreen> {
  final CameraService _cameraService = CameraService();
  final TextToSpeechService _tts = TextToSpeechService();
  final HeuristicGestureRecognitionService _recognitionService = HeuristicGestureRecognitionService();
  final engine.PhraseBuilder _phraseBuilder = engine.PhraseBuilder();
  StreamSubscription? _gestureSubscription;

  bool _isCameraInitialized = false;
  bool _cameraPermissionError = false;

  // Realtime display stats
  String _currentGesture = '';
  double _confidence = 0.0;
  String _engineState = 'Searching';
  String _displayText = '';
  List<String> _sequenceBuffer = [];
  List<List<engine.Landmark>>? _currentLandmarks;

  // Cooldown locks for vocalization
  int _lastSpokenTime = 0;
  static const int speechCooldownMs = 2500;

  @override
  void initState() {
    super.initState();
    _startTranslationSession();
  }

  Future<void> _startTranslationSession() async {
    // 1. Initialize Camera Feed
    try {
      await _cameraService.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
      
      // Fetch user custom gestures
      await _recognitionService.fetchCustomGestures(ref.read(apiServiceProvider));
      
      // Feed frame streams to processor
      await _cameraService.startImageStream((CameraImage img) {
        _recognitionService.processCameraImage(img);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _cameraPermissionError = true);
      }
      print('Translation Camera Init Error: $e');
    }

    // 2. Bind Gesture Listener
    _recognitionService.clearBuffer();
    _gestureSubscription = _recognitionService.gestureStream.listen((res) {
      if (!mounted) return;

      setState(() {
        _confidence = res.confidence;
        _engineState = res.state;
        _currentLandmarks = res.landmarks;
      });

      if (res.gesture != null && res.state == 'High Confidence') {
        _handleGestureDetected(res.gesture!);
      }
    });
  }

  Future<void> _handleGestureDetected(String gesture) async {
    // Standardize mapping for phrase evaluation
    String mappedGesture = gesture;
    if (gesture == 'EatWithMe') mappedGesture = 'FOOD';
    if (gesture == 'WhereGo') mappedGesture = 'WHERE';
    if (gesture == 'Yes') mappedGesture = 'HELP';
    if (gesture == 'Hello') mappedGesture = 'HELLO';

    // Map database ID to spoken label
    final Map<String, String> speakNames = {
      'Yes': 'Yes',
      'Stop': 'Stop',
      'No': 'No',
      'ILY': 'I Love You',
      'Hello': 'Hello',
      'ME': 'Me',
      'YOU': 'You',
      'WANT': 'Want',
      'NeedWater': 'Water',
      'HospitalWhere': 'Hospital',
      'EatWithMe': 'Eat',
      'PLEASE': 'Please',
      'SORRY': 'Sorry',
      'SIGN': 'Sign',
      'AGAIN': 'Again',
      'SLOW': 'Slow',
      'GO': 'Go'
    };

    final displayText = speakNames[gesture] ?? gesture;
    final autoVocalize = ref.read(autoVocalizeProvider);

    if (_currentGesture != displayText) {
      setState(() {
        _currentGesture = displayText;
        _displayText = displayText;
      });

      // Add to sequence builder
      final eval = _phraseBuilder.addGesture(mappedGesture);
      setState(() {
        _sequenceBuffer = List<String>.from(eval.buffer);
      });

      if (eval.isMatch && eval.phraseText != null) {
        // Speak completed translated sentence
        if (autoVocalize) {
          await _tts.speak(eval.phraseText!);
        }

        // Take snapshot image and save to database
        final snapshotBase64 = await _cameraService.captureBase64Frame();
        await ref.read(historyProvider.notifier).addRecord(
              eval.phraseText!,
              snapshotBase64,
            );

        setState(() {
          _displayText = eval.phraseText!;
          _sequenceBuffer = [];
        });

        // Clear displayed text after 3.5s delay
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (mounted) {
            setState(() {
              _displayText = '';
              _currentGesture = '';
            });
          }
        });
      } else {
        // Speak single word on cooldown
        final now = DateTime.now().millisecondsSinceEpoch;
        if (autoVocalize && (now - _lastSpokenTime > speechCooldownMs)) {
          await _tts.speak(displayText);
          _lastSpokenTime = now;
        }
      }
    }
  }

  void _clearTranslationBuffer() {
    _phraseBuilder.clear();
    _recognitionService.clearBuffer();
    setState(() {
      _sequenceBuffer = [];
      _currentGesture = '';
      _displayText = '';
      _confidence = 0.0;
    });
  }

  Future<void> _stopTranslationSession() async {
    _gestureSubscription?.cancel();
    _recognitionService.dispose();
    await _cameraService.stopImageStream();
    await _cameraService.dispose();
  }

  @override
  void dispose() {
    _stopTranslationSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final autoVocalize = ref.watch(autoVocalizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of simulated gesture buttons for developers/reviewers to tap
    final List<String> simulatedSignKeys = [
      'ME', 'WANT', 'EatWithMe', 'PLEASE', 'HELP', 'NeedWater', 'HospitalWhere', 
      'Hello', 'Stop', 'No', 'YOU', 'SORRY', 'SIGN', 'AGAIN', 'SLOW', 'GO'
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSlate : Colors.white,
        elevation: 0,
        title: Text(
          'Translation Console',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.darkSlate,
          ),
        ),
        actions: [
          // Clear buffer button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear sequence',
            onPressed: _clearTranslationBuffer,
          ),
          // Auto vocalize speaker toggler
          IconButton(
            icon: Icon(autoVocalize ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            tooltip: 'Toggle Speech',
            onPressed: () => ref.read(autoVocalizeProvider.notifier).state = !autoVocalize,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mirrored 4:3 Camera View Frame
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Camera display
                      if (_isCameraInitialized && _cameraService.controller != null)
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14159), // Mirror camera preview
                          child: CameraPreview(_cameraService.controller!),
                        )
                      else if (_cameraPermissionError)
                        const Center(child: Text('Camera permission required'))
                      else
                        const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan)),

                      // Draw Hand skeleton overlay if landmarks exist
                      if (_currentLandmarks != null)
                        CustomPaint(
                          painter: HandSkeletonPainter(_currentLandmarks),
                        ),

                      // Neon Boundary box guides
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.neonCyan.withOpacity(0.4),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // Status state overlay banners
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.neonCyan,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _engineState,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),

                      // Confidence score overlay
                      if (_confidence > 0)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'MATCH: ${(_confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(color: AppTheme.neonCyan, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Displays Translation Output & Sentence Builder Buffer
            Expanded(
              flex: 2,
              child: Card(
                color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Buffer details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SEQUENCE BUFFER',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          if (_sequenceBuffer.isNotEmpty)
                            Text(
                              '${_sequenceBuffer.length} tokens',
                              style: const TextStyle(color: AppTheme.neonPurple, fontSize: 10),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Tokens list
                      SizedBox(
                        height: 28,
                        child: _sequenceBuffer.isEmpty
                            ? const Text(
                                'Buffer is empty. Sign gestures to construct sentences.',
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _sequenceBuffer.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonPurple.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _sequenceBuffer[index],
                                      style: const TextStyle(color: AppTheme.neonPurple, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const Divider(height: 24, thickness: 0.5),

                      // Big translation printout
                      const Text(
                        'TRANSLATED TEXT',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: Text(
                            _displayText.isEmpty ? 'WAITING FOR INPUT...' : _displayText,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _displayText.isEmpty
                                  ? Colors.grey
                                  : (isDark ? Colors.white : AppTheme.darkSlate),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tap Simulator panel for easy reviews
            Card(
              color: isDark ? AppTheme.darkSlateSecondary.withOpacity(0.6) : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal_rounded, size: 14, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('Interactive Simulator Controls', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: simulatedSignKeys.length,
                        itemBuilder: (context, index) {
                          final gKey = simulatedSignKeys[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ActionChip(
                              label: Text(gKey, style: const TextStyle(fontSize: 9)),
                              backgroundColor: isDark ? AppTheme.darkSlate : Colors.white,
                              onPressed: () => _handleGestureDetected(gKey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
