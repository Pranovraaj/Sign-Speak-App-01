// lib/core/constants/app_constants.dart

class AppConstants {
  static const String appName = 'SignSpeak';

  // API Configs
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/api/v1', // Use 127.0.0.1 for Web/Desktop, 10.0.2.2 for Android Emulator, or your local IP (e.g. 192.168.x.x) for a real device
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String keyToken = 'jwt_auth_token';
  static const String keyRefreshToken = 'jwt_refresh_token';
  static const String keyUser = 'cached_user_data';
  static const String keyDarkMode = 'settings_dark_mode';
  static const String keyLanguage = 'settings_language';
  static const String keySpeechSpeed = 'settings_speech_speed';
  static const String keyPreferredVoice = 'settings_preferred_voice';

  // API Endpoints
  static const String endpointLogin = '/auth/login';
  static const String endpointRegister = '/auth/register';
  static const String endpointRefreshToken = '/auth/refresh';
  static const String endpointUserProfile = '/users/profile';
  static const String endpointHistory = '/history';
  static const String endpointHistoryPurge = '/history/purge';
  static const String endpointBookmarks = '/bookmarks';
  static const String endpointProgress = '/progress';
  static const String endpointCustomGestures = '/gestures/custom';

  // Default Categories
  static const List<String> categories = [
    'All',
    'Beginner',
    'Conversational',
    'Emergency',
    'Hospital',
    'Daily Conversation',
    'Technology',
    'Travel',
    'Emotion',
  ];
}
