// lib/features/tutorial/screens/quiz_challenge_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/ai_placeholder_services.dart';
import '../../../core/services/tts_service.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/gesture_model.dart';
import '../providers/tutorial_provider.dart';
import '../../../core/utils/gesture_engine.dart' as engine;
import '../../../core/widgets/hand_skeleton_painter.dart';

class QuizChallengeScreen extends ConsumerStatefulWidget {
  const QuizChallengeScreen({super.key});

  @override
  ConsumerState<QuizChallengeScreen> createState() => _QuizChallengeScreenState();
}

class _QuizChallengeScreenState extends ConsumerState<QuizChallengeScreen> {
  final TextToSpeechService _tts = TextToSpeechService();
  final HeuristicGestureRecognitionService _recognitionService = HeuristicGestureRecognitionService();
  StreamSubscription? _gestureSubscription;

  // Quiz States
  String _gameState = 'preparing'; // preparing, countdown, playing, correct, gameover
  int _score = 0;
  int _lives = 3;
  int _timeLeft = 15;
  int _preStartCountdown = 3;
  GestureModel? _currentGesture;
  List<GestureModel> _availableQuizGestures = [];
  Timer? _gameTimer;
  Timer? _countdownTimer;

  // Visual cues
  bool _flashGreen = false;
  bool _flashRed = false;
  List<List<engine.Landmark>>? _currentLandmarks;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    final repo = ref.read(tutorialRepositoryProvider);
    // Find gestures that support live ML tracking
    _availableQuizGestures = repo.getAllGestures().where((g) => g.isLiveRecognized).toList();
    _startPreCountdown();
  }

  void _startPreCountdown() {
    setState(() {
      _gameState = 'countdown';
      _preStartCountdown = 3;
      _score = 0;
      _lives = 3;
    });

    _tts.speak('Get ready! Three. Two. One. Go!');
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_preStartCountdown > 1) {
        setState(() {
          _preStartCountdown--;
        });
      } else {
        timer.cancel();
        _startNewQuestion();
      }
    });
  }

  void _startNewQuestion() {
    if (_lives <= 0) {
      _endGame();
      return;
    }

    if (_availableQuizGestures.isEmpty) return;

    final randIdx = Random().nextInt(_availableQuizGestures.length);
    setState(() {
      _currentGesture = _availableQuizGestures[randIdx];
      _gameState = 'playing';
      _timeLeft = 15;
      _flashGreen = false;
      _flashRed = false;
    });

    _tts.speak('Sign: ${_currentGesture!.name}');
    
    // Bind gesture detector subscriber
    _recognitionService.clearBuffer();
    _gestureSubscription?.cancel();
    _gestureSubscription = _recognitionService.gestureStream.listen((res) {
      if (!mounted) return;
      setState(() {
        _currentLandmarks = res.landmarks;
      });
      if (res.gesture != null && _gameState == 'playing') {
        _checkGestureResult(res.gesture!);
      }
    });

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 1) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _handleTimeOut();
      }
    });
  }

  void _checkGestureResult(String gestureId) {
    if (_currentGesture == null) return;
    
    // Map standard codes to match IDs if necessary
    if (gestureId.toLowerCase() == _currentGesture!.id.toLowerCase()) {
      _handleCorrectAnswer();
    }
  }

  void _handleCorrectAnswer() {
    _gameTimer?.cancel();
    _gestureSubscription?.cancel();
    
    setState(() {
      _score += 10;
      _gameState = 'correct';
      _flashGreen = true;
    });

    _tts.speak('Correct!');
    
    // Advance to next after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _startNewQuestion();
      }
    });
  }

  void _handleTimeOut() {
    _gestureSubscription?.cancel();
    setState(() {
      _lives--;
      _flashRed = true;
    });

    _tts.speak('Time is out!');

    // Flash and delay before continuing
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _startNewQuestion();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _gestureSubscription?.cancel();
    setState(() {
      _gameState = 'gameover';
    });

    // Save/Update local score cached values
    ref.read(authProvider.notifier).updateHighScore(_score);
    _tts.speak('Game over. Your score is $_score.');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    _gestureSubscription?.cancel();
    _recognitionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Quiz Challenge',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.darkSlate,
          ),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _flashGreen 
            ? Colors.green.withOpacity(0.1) 
            : (_flashRed ? Colors.red.withOpacity(0.1) : Colors.transparent),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Status Bar (Score, Timer, Lives)
            if (_gameState == 'playing' || _gameState == 'correct') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score Indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SCORE', style: TextStyle(fontSize: 10, letterSpacing: 1.5)),
                      Text(
                        '$_score pts',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                        ),
                      )
                    ],
                  ),
                  
                  // Countdown Clock
                  CircleAvatar(
                    backgroundColor: _timeLeft <= 5 ? Colors.red : AppTheme.neonPurple,
                    radius: 24,
                    child: Text(
                      '$_timeLeft',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // Hearts Lives
                  Row(
                    children: List.generate(
                      3,
                      (index) => Icon(
                        index < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Switch content based on GameState
            Expanded(
              child: _buildQuizBodyContent(isDark),
            ),

            // Heuristic Simulator Console for easy dev testing
            if (_gameState == 'playing') ...[
              const SizedBox(height: 16),
              Card(
                color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal_rounded, size: 16, color: Colors.grey),
                          SizedBox(width: 6),
                          Text('Dev Simulator shortcut', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableQuizGestures.length,
                          itemBuilder: (context, index) {
                            final g = _availableQuizGestures[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ActionChip(
                                label: Text(g.id, style: const TextStyle(fontSize: 10)),
                                onPressed: () {
                                  // Send simulated gesture
                                  _checkGestureResult(g.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildQuizBodyContent(bool isDark) {
    switch (_gameState) {
      case 'countdown':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GAME STARTS IN',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$_preStartCountdown',
                style: GoogleFonts.outfit(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonCyan,
                ),
              ),
            ],
          ),
        );
      case 'playing':
      case 'correct':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MAKE THE SIGN FOR:',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentGesture?.name ?? '',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.darkSlate,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Simulated camera scanner layer
            Container(
              height: 240,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? AppTheme.darkSlateSecondary : Colors.grey.shade200,
                border: Border.all(
                  color: _flashGreen 
                      ? Colors.green 
                      : (_flashRed ? Colors.red : AppTheme.neonCyan.withOpacity(0.3)),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.videocam_rounded, size: 48, color: Colors.grey),
                  if (_currentLandmarks != null)
                    CustomPaint(
                      painter: HandSkeletonPainter(_currentLandmarks),
                    ),
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _flashGreen ? 'Correct Sign!' : (_flashRed ? 'Time Out!' : 'Waiting for Gesture...'),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      case 'gameover':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_very_dissatisfied_rounded, size: 80, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'GAME OVER',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You completed the challenge with score:',
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                '$_score points',
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _startPreCountdown,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('PLAY AGAIN'),
              ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
