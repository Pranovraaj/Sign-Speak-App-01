// lib/features/authentication/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Real-time AI Translation',
      description: 'Point your camera and translate hand gestures instantly to voice and text using our heuristic engine.',
      icon: Icons.camera_front_rounded,
      color: AppTheme.neonCyan,
    ),
    OnboardingSlide(
      title: 'Learn Sign Language',
      description: 'Explore over 30 categories including emergency, hospital, travel, numbers, alphabets, and more.',
      icon: Icons.auto_stories_rounded,
      color: AppTheme.neonPurple,
    ),
    OnboardingSlide(
      title: 'Gamified Practice Mode',
      description: 'Practice signs in front of your camera, get instant correct/wrong feedback, and beat your high scores.',
      icon: Icons.sports_esports_rounded,
      color: Colors.greenAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _slides[_currentIndex].color.withOpacity(0.12),
              ),
            ),
          ),

          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSlateSecondary : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: slide.color.withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        slide.icon,
                        size: 80,
                        color: slide.color,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      slide.title,
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Slide indicator and button controls
          Positioned(
            bottom: 60,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index 
                            ? _slides[_currentIndex].color 
                            : Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Button Action
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _slides[_currentIndex].color,
                    foregroundColor: isDark ? AppTheme.darkSlate : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(_currentIndex == _slides.length - 1 ? 'Get Started' : 'Next'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
