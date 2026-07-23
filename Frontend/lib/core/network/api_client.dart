// lib/core/network/api_client.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1. Add Logging Interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('DioLog: $object'),
      ),
    );

    // 2. Add JWT Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: AppConstants.keyToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // 3. Handle Token Refresh on 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;
            final isRefreshed = await _attemptTokenRefresh();

            if (isRefreshed) {
              // Retry the original request with new token
              final newToken = await _secureStorage.read(key: AppConstants.keyToken);
              requestOptions.headers['Authorization'] = 'Bearer $newToken';
              
              try {
                final response = await _dio.request(
                  requestOptions.path,
                  options: Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                  ),
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                );
                return handler.resolve(response);
              } catch (retryError) {
                return handler.reject(
                  DioException(
                    requestOptions: requestOptions,
                    error: retryError,
                  ),
                );
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Attempt to refresh JWT with stored refresh token
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken == null) return false;

      // Create a separate dio client to avoid refresh token request triggering recursive refresh loops
      final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      final response = await refreshDio.post(
        AppConstants.endpointRefreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final newAccessToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _secureStorage.write(key: AppConstants.keyToken, value: newAccessToken);
          if (newRefreshToken != null) {
            await _secureStorage.write(key: AppConstants.keyRefreshToken, value: newRefreshToken);
          }
          return true;
        }
      }
    } catch (e) {
      print('Token refresh failed: $e');
      // If refresh fails, purge tokens
      await logout();
    }
    return false;
  }

  // HTTP Helper Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // Parse HTTP Errors to standard custom exceptions
  ApiException _parseError(DioException error) {
    String message = 'An unexpected connection error occurred';
    int statusCode = error.response?.statusCode ?? 500;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'Connection timed out. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Server is unreachable. Please verify you are connected to the network.';
    } else if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data is Map && data.containsKey('error')) {
        message = data['error'].toString();
      } else {
        message = 'Server error status: ${error.response?.statusCode}';
      }
    }
    return ApiException(message, statusCode);
  }

  // Session Management
  Future<void> saveSession(String token, String refreshToken) async {
    await _secureStorage.write(key: AppConstants.keyToken, value: token);
    await _secureStorage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.keyToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }

  Future<bool> hasSession() async {
    final token = await _secureStorage.read(key: AppConstants.keyToken);
    return token != null;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
