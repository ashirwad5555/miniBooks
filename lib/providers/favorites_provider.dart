//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// // Define a class to represent a book
// class Book {
//   final String id;
//   final String title;
//   final String author;
//   final String coverUrl;
//
//   Book({required this.id, required this.title, required this.author, required this.coverUrl});
// }
//
// // Create a NotifierProvider to manage the list of favorite books
// class FavoriteBooksNotifier extends Notifier<List<Map<String, dynamic>>> {
//   @override
//   List<Map<String, dynamic>> build() {
//     return [];
//   }
//
//   void addFavorite(Map<String, dynamic> book) {
//     if (!state.any((favoriteBook) => favoriteBook.id == book.id)) {
//       state = [...state, book];
//     }
//   }
//
//   void removeFavorite(String bookId) {
//     state = state.where((book) => book.id != bookId).toList();
//   }
// }
//
// final favoriteBooksProvider = NotifierProvider<FavoriteBooksNotifier, List<Book>>(FavoriteBooksNotifier.new);


import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]);

  void toggleFavorite(String bookId) {
    if (state.contains(bookId)) {
      state = state.where((id) => id != bookId).toList(); // Remove if already favorite
    } else {
      state = [...state, bookId]; // Add to favorites
    }
  }

  bool isFavorite(String bookId) {
    return state.contains(bookId);
  }
}
