// book_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/data/all_books.dart';

import 'all_books_provider.dart';

// Provider for fetching initial books data
final booksDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Replace this with your actual data fetching logic
  return Future.value(books);
});

// Provider specifically for genres
final genresProvider = Provider<Set<String>>((ref) {
  final books = ref.watch(booksProvider);
  final Set<String> allGenres = {};

  for (final book in books) {
    final genres = book['genres'];
    if (genres != null && genres is List) {
      for (final genre in genres) {
        if (genre is String) {
          allGenres.add(genre);
        }
      }
    }
  }

  return allGenres;
});

// Provider for managing books state
final booksProvider1 = StateNotifierProvider<BooksNotifier, List<Map<String, dynamic>>>((ref) {
  final booksNotifier = BooksNotifier();

  // Listen to booksDataProvider and update state when data is available
  ref.listen(booksDataProvider, (previous, next) {
    next.whenData((books) {
      booksNotifier.setBooks(books);
    });
  });

  return booksNotifier;
});

class BooksNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  BooksNotifier() : super([]);

  void setBooks(List<Map<String, dynamic>> books) {
    state = books;
  }

  Set<String> getAllGenres() {
    final Set<String> genres = {};
    for (var book in state) {
      if (book['genres'] != null) {
        final List<String> bookGenres = List<String>.from(book['genres']);
        genres.addAll(bookGenres);
      }
    }
    return genres;
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredBooksProvider1 = Provider<List<Map<String, dynamic>>>((ref) {
  final books = ref.watch(booksProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) return books;

  final lowercaseQuery = query.toLowerCase();
  return books.where((book) {
    return (book['title'] ?? '').toLowerCase().contains(lowercaseQuery) ||
        (book['author'] ?? '').toLowerCase().contains(lowercaseQuery) ||
        (book['genres'] as List<String>?)?.any((genre) =>
            genre.toLowerCase().contains(lowercaseQuery)) == true ||
        (book['category'] ?? '').toLowerCase().contains(lowercaseQuery);
  }).toList();
});

// Provider for books of a specific genre
final booksByGenreProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, genre) {
  final books = ref.watch(booksProvider);
  return books.where((book) {
    final genres = (book['genres'] as List?)?.cast<String>() ?? [];
    return genres.contains(genre);
  }).toList();
});