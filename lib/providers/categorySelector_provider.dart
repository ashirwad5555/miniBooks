
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'all_books_provider.dart';




// Provider to get all unique categories
final categoriesProvider = Provider<List<String>>((ref) {
  final books = ref.watch(booksProvider);
  final categories = books.map((book) => book['category'] as String).toSet().toList();
  categories.sort(); // Sort categories alphabetically
  return categories;
});

// Provider to store the currently selected category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider to filter books by the selected category
final filteredBooksProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final books = ref.watch(booksProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  if (selectedCategory == null) {
    return books; // Return all books if no category is selected
  }
  return books.where((book) => book['category'] == selectedCategory).toList();
});
