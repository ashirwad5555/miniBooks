//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import 'all_books_provider.dart';
//
//
//
//
// // Provider to get all unique categories
// final categoriesProvider = Provider<List<String>>((ref) {
//   final books = ref.watch(booksProvider);
//   final categories = books.map((book) => book['category'] as String).toSet().toList();
//   categories.sort(); // Sort categories alphabetically
//   return categories;
// });
//
// // Provider to store the currently selected category
// final selectedCategoryProvider = StateProvider<String?>((ref) => null);
//
// // Provider to filter books by the selected category
// final filteredBooksProvider = Provider<List<Map<String, dynamic>>>((ref) {
//   final books = ref.watch(booksProvider);
//   final selectedCategory = ref.watch(selectedCategoryProvider);
//   if (selectedCategory == null) {
//     return books; // Return all books if no category is selected
//   }
//   return books.where((book) => book['category'] == selectedCategory).toList();
// });

//after using BrainChain Book Data
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'all_books_provider.dart';

// Provider to get all unique categories from the new JSON format
final categoriesProvider = Provider<List<String>>((ref) {
  final books = ref.watch(booksProvider);

  // Extract all category tags from all books
  final categoriesSet = <String>{};
  for (final book in books) {
    final categoryTags = book['category Tags'] as List<dynamic>? ?? [];
    categoriesSet.addAll(categoryTags.map((tag) => tag.toString().trim()));
  }

  final categoriesList = categoriesSet.toList();
  categoriesList.sort(); // Sort categories alphabetically
  return categoriesList;
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

  // Filter books that contain the selected category in their tags
  return books.where((book) {
    final categoryTags = book['category Tags'] as List<dynamic>? ?? [];
    return categoryTags.any((tag) => tag.toString().trim() == selectedCategory);
  }).toList();
});
