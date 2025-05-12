import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/data/books_data.dart';

// State class for book search
class BookSearchState {
  final List<Map<String, dynamic>> filteredBooks;
  final String searchQuery;
  final String? selectedCategory;

  BookSearchState({
    required this.filteredBooks,
    this.searchQuery = '',
    this.selectedCategory,
  });

  BookSearchState copyWith({
    List<Map<String, dynamic>>? filteredBooks,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return BookSearchState(
      filteredBooks: filteredBooks ?? this.filteredBooks,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory,
    );
  }
}

// Notifier class for book search logic
class BookSearchNotifier extends StateNotifier<BookSearchState> {
  BookSearchNotifier() : super(BookSearchState(filteredBooks: allBooks));

  void searchBooks(String query) {
    if (query.isEmpty) {
      if (state.selectedCategory != null) {
        // If we have a category selected, filter by that category
        final filtered = allBooks.where((book) {
          return book['main_tag'] == state.selectedCategory;
        }).toList();
        state = BookSearchState(
            filteredBooks: filtered,
            searchQuery: query,
            selectedCategory: state.selectedCategory);
      } else {
        // No category selected, show all books
        state = BookSearchState(filteredBooks: allBooks, searchQuery: query);
      }
    } else {
      final lowercaseQuery = query.toLowerCase();
      List<Map<String, dynamic>> baseList = state.selectedCategory != null
          ? allBooks
              .where((book) => book['main_tag'] == state.selectedCategory)
              .toList()
          : allBooks;

      final filtered = baseList.where((book) {
        // Search by title
        final title = book['title'].toString().toLowerCase();
        if (title.contains(lowercaseQuery)) {
          return true;
        }

        // Search by author (if available)
        final author = book['author'].toString().toLowerCase();
        if (author.contains(lowercaseQuery)) {
          return true;
        }

        // Search by category tags
        final categoryTags = book['category Tags'] as List?;
        if (categoryTags != null) {
          for (final tag in categoryTags) {
            if (tag.toString().toLowerCase().contains(lowercaseQuery)) {
              return true;
            }
          }
        }

        return false;
      }).toList();

      state = BookSearchState(
          filteredBooks: filtered,
          searchQuery: query,
          selectedCategory: state.selectedCategory);
    }
  }

  void selectCategory(String? category) {
    if (category == null) {
      // Reset to show all books
      state = BookSearchState(
          filteredBooks: allBooks,
          searchQuery: state.searchQuery,
          selectedCategory: null);
    } else {
      // Filter books by the selected category
      final filtered =
          allBooks.where((book) => book['main_tag'] == category).toList();
      state = BookSearchState(
          filteredBooks: filtered,
          searchQuery: state.searchQuery,
          selectedCategory: category);
    }
  }

  void clearSearch() {
    if (state.selectedCategory != null) {
      // Keep the category filter
      selectCategory(state.selectedCategory);
    } else {
      // Clear everything
      state = BookSearchState(filteredBooks: allBooks, searchQuery: '');
    }
  }

  void resetFilters() {
    state = BookSearchState(filteredBooks: allBooks, searchQuery: '');
  }
}

// Create a provider to get unique categories
final categoriesProvider = Provider<List<String>>((ref) {
  final Set<String> uniqueCategories = {};

  for (var book in allBooks) {
    final mainTag = book['main_tag'];
    if (mainTag != null && mainTag is String && mainTag.isNotEmpty) {
      uniqueCategories.add(mainTag);
    }
  }

  final List<String> categories = uniqueCategories.toList();
  categories.sort(); // Sort alphabetically

  return categories;
});

// Add this to providers.dart
// Provider to get unique category tags (not main categories)
final categoryTagsProvider = Provider<List<String>>((ref) {
  final Set<String> uniqueTags = {};

  for (var book in allBooks) {
    final categoryTags = book['category Tags'] as List?;
    if (categoryTags != null) {
      for (final tag in categoryTags) {
        if (tag is String && tag.isNotEmpty) {
          uniqueTags.add(tag);
        }
      }
    }
  }

  final List<String> tags = uniqueTags.toList();
  tags.sort(); // Sort alphabetically

  return tags;
});

// Selected tag provider
final selectedTagProvider = StateProvider<String?>((ref) => null);

// Create the book search provider
final bookSearchProvider =
    StateNotifierProvider<BookSearchNotifier, BookSearchState>((ref) {
  return BookSearchNotifier();
});

// Search controller provider
final searchControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
