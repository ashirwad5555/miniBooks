import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart';
import 'package:mini_books/data/books_data.dart';
import 'package:mini_books/providers/explore_book_provider.dart';

class ExploreBody extends ConsumerWidget {
  const ExploreBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the search state
    final searchState = ref.watch(bookSearchProvider);
    final filteredBooks = searchState.filteredBooks;
    final categories = ref.watch(categoriesProvider);

    // Access the search controller
    final searchController = ref.watch(searchControllerProvider);

    // Keep search controller in sync with state
    if (searchController.text != searchState.searchQuery) {
      searchController.text = searchState.searchQuery;
    }

    // Determine whether to show categories or filtered books
    final bool showingCategories =
        searchState.selectedCategory == null && searchState.searchQuery.isEmpty;

    return Scaffold(
      body: Column(
        children: [
          // Search box
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Light background color
                borderRadius: BorderRadius.circular(24), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Subtle shadow
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: TextField(
                controller: searchController, // Set the controller
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  hintText: 'Search books, authors, genres...',
                  hintStyle: TextStyle(
                      color: Colors.grey[600]), // Softer hint text color
                  border: InputBorder.none, // Remove default border
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.grey), // Add a search icon
                  suffixIcon: searchState.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            ref.read(bookSearchProvider.notifier).clearSearch();
                          },
                        )
                      : null,
                ),
                onChanged: (query) {
                  ref.read(bookSearchProvider.notifier).searchBooks(query);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: TextField(
          //     controller: searchController,
          //     decoration: InputDecoration(
          //       hintText: 'Search by title, author, or category',
          //       prefixIcon: const Icon(Icons.search),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(10.0),
          //       ),
          //       suffixIcon: searchState.searchQuery.isNotEmpty
          //           ? IconButton(
          //               icon: const Icon(Icons.clear),
          //               onPressed: () {
          //                 searchController.clear();
          //                 ref.read(bookSearchProvider.notifier).clearSearch();
          //               },
          //             )
          //           : null,
          //     ),
          //     onChanged: (query) {
          //       ref.read(bookSearchProvider.notifier).searchBooks(query);
          //     },
          //   ),
          // ),

          // Category chip (if category is selected)
          if (searchState.selectedCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      'Category: ${searchState.selectedCategory}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor:
                        _getCategoryColor(searchState.selectedCategory!),
                    deleteIcon: const Icon(
                      Icons.cancel,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onDeleted: () {
                      ref.read(bookSearchProvider.notifier).resetFilters();
                    },
                  ),
                ],
              ),
            ),

          // Results count or categories title
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: showingCategories
                  ? null
                  : Text(
                      'Found ${filteredBooks.length} ${filteredBooks.length == 1 ? "book" : "books"}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
          ),

          // Categories grid or Book list
          Expanded(
            child: showingCategories
                ? _buildCategoriesGrid(categories, ref)
                : _buildBooksList(filteredBooks, context),
          ),
        ],
      ),
    );
  }

  // Helper method to get a consistent color for a category
  Color _getCategoryColor(String category) {
    final int hash = category.hashCode;

    switch (hash % 6) {
      case 0:
        return Colors.blue.shade600;
      case 1:
        return Colors.purple.shade600;
      case 2:
        return Colors.teal.shade600;
      case 3:
        return Colors.orange.shade600;
      case 4:
        return Colors.pink.shade600;
      case 5:
        return Colors.green.shade600;
      default:
        return Colors.blueGrey.shade600;
    }
  }

  Widget _buildCategoriesGrid(List<String> categories, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Add bottom padding
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          // Get count of books in this category
          final int bookCount = ref
              .watch(bookSearchProvider.notifier)
              .state
              .filteredBooks
              .where((book) => book['main_tag'] == category)
              .length;

          return CategoryCard(
            title: category,
            bookCount: bookCount,
            onTap: () {
              ref.read(bookSearchProvider.notifier).selectCategory(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildBooksList(
      List<Map<String, dynamic>> books, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Add bottom padding
      child: books.isEmpty
          ? const Center(
              child: Text(
                'No books found matching your search',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: books.length,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensure scrollable
              padding: const EdgeInsets.only(
                  bottom: 16.0), // Additional padding at the end of list
              itemBuilder: (context, index) {
                final book = books[index];
                print(book);
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  elevation: 3.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.asset(
                        'assets/${book['coverImage']}',
                        width: 50,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.book,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                    title: Text(
                      book['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      book['author'].isEmpty
                          ? 'Unknown Author'
                          : book['author'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetails(bookData: book),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final int bookCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.bookCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          // Remove the fixed height that was causing the overflow
          // height: 500,  <-- Remove this line
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getColorsForCategory(title),
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Slightly increased padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // This will prevent overflow
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Slightly reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Limit to 2 lines for long titles
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis for text overflow
                ),
                const SizedBox(height: 4), // Reduced height
                Text(
                  '$bookCount ${bookCount == 1 ? 'book' : 'books'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12, // Slightly reduced font size
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get colors based on category name for visual distinction
  List<Color> _getColorsForCategory(String category) {
    // Generate a consistent color based on the category name
    final int hash = category.hashCode;

    switch (hash % 6) {
      case 0:
        return [Colors.blue.shade700, Colors.blue.shade400];
      case 1:
        return [Colors.purple.shade700, Colors.purple.shade400];
      case 2:
        return [Colors.teal.shade700, Colors.teal.shade400];
      case 3:
        return [Colors.orange.shade700, Colors.orange.shade400];
      case 4:
        return [Colors.pink.shade700, Colors.pink.shade400];
      case 5:
        return [Colors.green.shade700, Colors.green.shade400];
      default:
        return [Colors.blueGrey.shade700, Colors.blueGrey.shade400];
    }
  }
}
