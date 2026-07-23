// lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';

import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/onboarding_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/profile_setup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String profileSetup = '/profile_setup';
  static const String dashboard = '/dashboard';
  static const String tutorials = '/tutorials';
  static const String practice = '/practice';
  static const String liveTranslation = '/live_translation';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildAnimatedRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildAnimatedRoute(const OnboardingScreen(), settings);
      case login:
        return _buildAnimatedRoute(const LoginScreen(), settings);
      case profileSetup:
        return _buildAnimatedRoute(const ProfileSetupScreen(), settings);
      case dashboard:
        return _buildAnimatedRoute(const DashboardScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Smooth custom animation for screen transitions
  static PageRouteBuilder _buildAnimatedRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
