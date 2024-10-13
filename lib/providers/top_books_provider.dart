import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'all_books_provider.dart';

// Assume we have imported the books data from the previous artifact
// import 'book_data.dart';

final topBooksProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final books = ref.watch(booksProvider);
  // Sort the books by views in descending order
  final sortedBooks = List<Map<String, dynamic>>.from(books)
    ..sort((a, b) => (b['views'] as int).compareTo(a['views'] as int));

  // Return the top 4 books
  return sortedBooks.take(4).toList();
});