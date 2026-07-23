// lib/features/tutorial/providers/tutorial_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/gesture_model.dart';
import '../repository/tutorial_repository.dart';

// Inject repository
final tutorialRepositoryProvider = Provider<TutorialRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return TutorialRepository(prefs);
});

// Category filter provider
final activeCategoryProvider = StateProvider<String>((ref) => 'All');

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Bookmarks list provider
class BookmarksNotifier extends StateNotifier<Set<String>> {
  final TutorialRepository _repository;
  final String _userId;

  BookmarksNotifier(this._repository, this._userId) : super({}) {
    _load();
  }

  void _load() {
    state = _repository.getBookmarks(_userId).toSet();
  }

  Future<void> toggle(String gestureId) async {
    await _repository.toggleBookmark(_userId, gestureId);
    _load();
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<String>>((ref) {
  final repo = ref.watch(tutorialRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id ?? 'guest';
  return BookmarksNotifier(repo, userId);
});

// Progress list provider
class ProgressNotifier extends StateNotifier<Set<String>> {
  final TutorialRepository _repository;
  final String _userId;

  ProgressNotifier(this._repository, this._userId) : super({}) {
    _load();
  }

  void _load() {
    state = _repository.getProgress(_userId).toSet();
  }

  Future<void> complete(String gestureId) async {
    await _repository.completeGesture(_userId, gestureId);
    _load();
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, Set<String>>((ref) {
  final repo = ref.watch(tutorialRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id ?? 'guest';
  return ProgressNotifier(repo, userId);
});

// Filtered gestures provider (reactive filtering)
final filteredGesturesProvider = Provider<List<GestureModel>>((ref) {
  final repo = ref.watch(tutorialRepositoryProvider);
  final category = ref.watch(activeCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  var list = repo.getAllGestures();

  if (category != 'All') {
    list = list.where((g) => g.category.toLowerCase() == category.toLowerCase()).toList();
  }

  if (query.isNotEmpty) {
    list = list.where((g) {
      return g.name.toLowerCase().contains(query) || 
             g.description.toLowerCase().contains(query);
    }).toList();
  }

  return list;
});
