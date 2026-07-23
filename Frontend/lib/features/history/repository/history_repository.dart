// lib/features/history/repository/history_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/history_item.dart';

class HistoryRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  HistoryRepository(this._apiClient, this._prefs);

  static const String keyHistoryLocal = 'user_history_logs_cache';

  Future<List<HistoryItem>> fetchHistory(String userId) async {
    try {
      final response = await _apiClient.get(
        AppConstants.endpointHistory,
        queryParameters: {'userId': userId},
      );

      final List<dynamic> listJson = response.data;
      final list = listJson.map((x) => HistoryItem.fromJson(x)).toList();
      await cacheHistory(userId, list);
      return list;
    } on ApiException catch (e) {
      if (statusCodeIsOffline(e.statusCode)) {
        return getCachedHistory(userId);
      }
      rethrow;
    } catch (_) {
      return getCachedHistory(userId);
    }
  }

  Future<HistoryItem> saveRecord(String userId, String text, String? base64Image) async {
    final payload = {
      'userId': userId,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'image': base64Image,
    };

    try {
      final response = await _apiClient.post(
        AppConstants.endpointHistory,
        data: payload,
      );
      final item = HistoryItem.fromJson(response.data);
      
      // Update local cache
      final list = getCachedHistory(userId);
      list.insert(0, item);
      await cacheHistory(userId, list);

      return item;
    } on ApiException catch (e) {
      if (statusCodeIsOffline(e.statusCode)) {
        // Mock save locally
        final item = HistoryItem(
          id: 'local_hist_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          text: text,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          image: base64Image,
        );
        final list = getCachedHistory(userId);
        list.insert(0, item);
        await cacheHistory(userId, list);
        return item;
      }
      rethrow;
    }
  }

  Future<void> deleteRecord(String userId, String recordId) async {
    try {
      await _apiClient.delete('${AppConstants.endpointHistory}/$recordId');
    } on ApiException catch (e) {
      if (!statusCodeIsOffline(e.statusCode)) {
        rethrow;
      }
    }
    
    // Remove locally
    final list = getCachedHistory(userId);
    list.removeWhere((item) => item.id == recordId);
    await cacheHistory(userId, list);
  }

  Future<void> purgeHistory(String userId) async {
    try {
      await _apiClient.delete(AppConstants.endpointHistoryPurge);
    } on ApiException catch (e) {
      if (!statusCodeIsOffline(e.statusCode)) {
        rethrow;
      }
    }

    // Purge locally
    await _prefs.remove('${keyHistoryLocal}_$userId');
  }

  // Local Cache Helpers
  List<HistoryItem> getCachedHistory(String userId) {
    final dataStr = _prefs.getString('${keyHistoryLocal}_$userId');
    if (dataStr == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(dataStr);
      return jsonList.map((x) => HistoryItem.fromJson(x)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> cacheHistory(String userId, List<HistoryItem> list) async {
    final listJson = list.map((x) => x.toJson()).toList();
    await _prefs.setString('${keyHistoryLocal}_$userId', json.encode(listJson));
  }

  bool statusCodeIsOffline(int code) {
    return code == 503 || code == 500 || code == 404 || code == 0;
  }
}
