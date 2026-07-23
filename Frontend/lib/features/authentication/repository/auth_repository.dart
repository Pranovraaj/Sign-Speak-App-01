// lib/features/authentication/repository/auth_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthRepository(this._apiClient, this._prefs);

  // Simple client-side SHA256 helper matching Capacitor React hashing
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        AppConstants.endpointLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      await _apiClient.saveSession(token, refreshToken);

      final user = UserModel.fromJson(response.data['user']);
      await cacheUser(user);
      return user;
    } on ApiException catch (e) {
      // Local fallback for offline mode/development without backend running
      if (statusCodeIsOffline(e.statusCode)) {
        return await _mockLocalAuth(email, password, isLogin: true);
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register(String email, String password, {String preferredVoice = 'default'}) async {
    try {
      final response = await _apiClient.post(
        AppConstants.endpointRegister,
        data: {
          'email': email,
          'password': password,
          'preferredVoice': preferredVoice,
        },
      );

      final token = response.data['token'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      await _apiClient.saveSession(token, refreshToken);

      final user = UserModel.fromJson(response.data['user']);
      await cacheUser(user);
      return user;
    } on ApiException catch (e) {
      if (statusCodeIsOffline(e.statusCode)) {
        return await _mockLocalAuth(email, password, preferredVoice: preferredVoice, isLogin: false);
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cacheUser(UserModel user) async {
    await _prefs.setString(AppConstants.keyUser, json.encode(user.toJson()));
  }

  UserModel? getCachedUser() {
    final userStr = _prefs.getString(AppConstants.keyUser);
    if (userStr == null) return null;
    try {
      return UserModel.fromJson(json.decode(userStr));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    await _prefs.remove(AppConstants.keyUser);
    await _apiClient.logout();
  }

  bool statusCodeIsOffline(int code) {
    return code == 503 || code == 500 || code == 404 || code == 0;
  }

  // Fallback simulator database using SharedPreferences
  Future<UserModel> _mockLocalAuth(
    String email,
    String password, {
    String? preferredVoice,
    required bool isLogin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final usersKey = 'mock_users_db';
    final userListStr = _prefs.getString(usersKey) ?? '[]';
    final List<dynamic> usersJson = json.decode(userListStr);
    
    if (isLogin) {
      final match = usersJson.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );

      if (match == null) {
        throw ApiException('Invalid credentials (Local Heuristic Fallback)', 400);
      }
      return UserModel.fromJson(match);
    } else {
      // Check duplicates
      final isDuplicate = usersJson.any((u) => u['email'] == email);
      if (isDuplicate) {
        throw ApiException('Email already registered locally', 400);
      }

      final newUser = {
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'email': email.toLowerCase().trim(),
        'password': password,
        'preferredVoice': preferredVoice ?? 'default',
      };

      usersJson.add(newUser);
      await _prefs.setString(usersKey, json.encode(usersJson));
      return UserModel.fromJson(newUser);
    }
  }
}
