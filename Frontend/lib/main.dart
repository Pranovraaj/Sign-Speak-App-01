// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'features/authentication/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load SharedPreferences before running application to enable synchronous reads
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the SharedPreferences instance
        sharedPrefsProvider.overrideWithValue(sharedPrefs),
      ],
      child: const SignSpeakApp(),
    ),
  );
}

class SignSpeakApp extends ConsumerWidget {
  const SignSpeakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Determine the theme dynamically based on user settings
    final ThemeMode selectedThemeMode;
    if (user != null) {
      selectedThemeMode = user.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } else {
      // Default to dark theme for that sleek futuristic look
      selectedThemeMode = ThemeMode.dark;
    }

    return MaterialApp(
      title: 'SignSpeak',
      debugShowCheckedModeBanner: false,
      themeMode: selectedThemeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
