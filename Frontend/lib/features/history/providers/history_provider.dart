// lib/features/history/providers/history_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/history_item.dart';
import '../repository/history_repository.dart';

// Inject Repository
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return HistoryRepository(api, prefs);
});

// State notifier for history logs list
class HistoryNotifier extends StateNotifier<List<HistoryItem>> {
  final HistoryRepository _repository;
  final String _userId;

  HistoryNotifier(this._repository, this._userId) : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final list = await _repository.fetchHistory(_userId);
      state = list;
    } catch (e) {
      print('History Load Error: $e');
      // Load fallback cache immediately
      state = _repository.getCachedHistory(_userId);
    }
  }

  Future<void> addRecord(String text, String? base64Image) async {
    try {
      final record = await _repository.saveRecord(_userId, text, base64Image);
      state = [record, ...state];
    } catch (e) {
      print('Failed to save record: $e');
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await _repository.deleteRecord(_userId, recordId);
      state = state.where((item) => item.id != recordId).toList();
    } catch (e) {
      print('Failed to delete record: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.purgeHistory(_userId);
      state = [];
    } catch (e) {
      print('Failed to purge history: $e');
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryItem>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id ?? 'guest';
  return HistoryNotifier(repo, userId);
});

// Search query for history
final historySearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered history list provider
final filteredHistoryProvider = Provider<List<HistoryItem>>((ref) {
  final history = ref.watch(historyProvider);
  final query = ref.watch(historySearchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) return history;

  return history.where((item) {
    return item.text.toLowerCase().contains(query);
  }).toList();
});
