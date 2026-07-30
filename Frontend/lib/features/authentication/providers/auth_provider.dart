// lib/features/authentication/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

// Dependency injection providers
final apiServiceProvider = Provider<ApiClient>((ref) => ApiClient());

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return AuthRepository(api, prefs);
});

// Authentication State representation
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Authentication State notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _initSession();
  }

  void _initSession() {
    final cachedUser = _repository.getCachedUser();
    if (cachedUser != null) {
      state = AuthState(user: cachedUser);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String username, {String preferredVoice = 'default'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(email, password, username, preferredVoice: preferredVoice);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateSettings({String? voice, String? theme, String? username}) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    final updatedUser = currentUser.copyWith(
      preferredVoice: voice ?? currentUser.preferredVoice,
      theme: theme ?? currentUser.theme,
      username: username ?? currentUser.username,
    );
    await _repository.cacheUser(updatedUser);
    state = state.copyWith(user: updatedUser);
  }

  Future<void> updateProfileDetails({String? username, String? profilePictureBase64, String? newEmail, String? newPassword}) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    try {
      final updatedUser = await _repository.updateProfile(
        currentUser.email,
        username: username,
        profilePictureBase64: profilePictureBase64,
        newEmail: newEmail,
        newPassword: newPassword,
      );
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      // Failed to update profile on backend
      print('Update profile error: $e');
      rethrow;
    }
  }

  Future<void> incrementStreak() async {
    final currentUser = state.user;
    if (currentUser == null) return;
    try {
      final updatedUser = await _repository.updateStats(
        currentUser.email,
        streak: currentUser.streak + 1,
      );
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      print('Increment streak error: $e');
    }
  }

  Future<void> updateHighScore(int score) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    if (score > currentUser.highScore) {
      try {
        final updatedUser = await _repository.updateStats(
          currentUser.email,
          score: score,
        );
        state = state.copyWith(user: updatedUser);
      } catch (e) {
        print('Update score error: $e');
      }
    }
  }

  Future<void> logout() async {
    await _repository.clearCache();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
