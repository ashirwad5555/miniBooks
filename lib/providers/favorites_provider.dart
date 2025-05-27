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

  void addFavoriteBook(Map<String, dynamic> book) {
    if (!state.contains(book)) {
      final updatedState = [...state, book];
      state = updatedState;
      StorageService.saveFavoriteBooks(updatedState);
    }
  }

  void removeFavoriteBook(Map<String, dynamic> book) {
    final updatedState = state.where((b) => b != book).toList();
    state = updatedState;
    StorageService.saveFavoriteBooks(updatedState);
  }

  bool isBookFavorite(Map<String, dynamic> book) {
    return state.contains(book);
  }
}

final favoriteBooksProvider =
    StateNotifierProvider<FavoriteBooksNotifier, List<Map<String, dynamic>>>(
  (ref) => FavoriteBooksNotifier(),
);
