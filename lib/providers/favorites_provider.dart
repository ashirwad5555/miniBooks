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


// Favorite books provider
// Favorite books notifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteBooksNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoriteBooksNotifier() : super([]);

  void addFavoriteBook(Map<String, dynamic> book) {
    if (!state.contains(book)) {
      state = [...state, book];
    }
  }

  void removeFavoriteBook(Map<String, dynamic> book) {
    state = state.where((b) => b != book).toList();
  }

  bool isBookFavorite(Map<String, dynamic> book) {
    return state.contains(book);
  }
}

// Provider for favorite books
final favoriteBooksProvider = StateNotifierProvider<FavoriteBooksNotifier, List<Map<String, dynamic>>>(
      (ref) => FavoriteBooksNotifier(),
);
