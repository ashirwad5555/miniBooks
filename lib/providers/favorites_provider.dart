import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class FavoriteBooksNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoriteBooksNotifier() : super([]) {
    _initializeState();
  }

  Future<void> _initializeState() async {
    final savedBooks = await StorageService.loadFavoriteBooks();
    state = savedBooks;
  }

  // Add a method to refresh favorites from the server
  Future<void> refreshFavorites() async {
    final savedBooks = await StorageService.loadFavoriteBooks();
    state = savedBooks;
  }

  void addFavoriteBook(Map<String, dynamic> book) {
    if (!isBookFavorite(book)) {
      final updatedState = [...state, book];
      state = updatedState;
      StorageService.saveFavoriteBooks(updatedState);
    }
  }

  void removeFavoriteBook(Map<String, dynamic> book) {
    // Keep your existing removal logic but improve comparison
    final updatedState = state.where((b) => !_isSameBook(b, book)).toList();
    state = updatedState;
    StorageService.saveFavoriteBooks(updatedState);
  }

  bool isBookFavorite(Map<String, dynamic> book) {
    // Improve book comparison to work better across devices
    return state.any((b) => _isSameBook(b, book));
  }

  // Helper method for more reliable book comparison
  bool _isSameBook(Map<String, dynamic> a, Map<String, dynamic> b) {
    // First try to compare by ID if available
    if (a.containsKey('id') && b.containsKey('id')) {
      return a['id'] == b['id'];
    }

    // Fall back to title and author comparison
    return a['title'] == b['title'] && a['author'] == b['author'];
  }
}

final favoriteBooksProvider =
    StateNotifierProvider<FavoriteBooksNotifier, List<Map<String, dynamic>>>(
  (ref) => FavoriteBooksNotifier(),
);
