// lib/features/authentication/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 2.5 seconds simulated delay
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkSlate,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient neon glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glowCyan,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glowPurple,
              ),
            ),
          ),
          // Logo & Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 2,
                      )
                    ],
                    color: AppTheme.darkSlateSecondary,
                  ),
                  child: const Icon(
                    Icons.sign_language_rounded,
                    size: 80,
                    color: AppTheme.neonCyan,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SignSpeak',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI-POWERED TRANSLATION',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neonPurple,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 80),
                const SpinKitDoubleBounce(
                  color: AppTheme.neonCyan,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
