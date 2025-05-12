import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart';
import 'package:mini_books/Screens/temp/test_book_sammaryPage.dart';

import '../../providers/categorySelector_provider.dart';
import '../BookSummaryPage/book_summary_page.dart';

class CategoryBooksWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredBooks = ref.watch(filteredBooksProvider);

    return SizedBox(
      height: 550, // Increased from 450 to give more room for the grid
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Top picks for you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Horizontal scrollable book list with views and rating
          Expanded(
            child: Column(
              children: [
                // Category selection - Keep this compact
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8), // Reduced vertical margin
                  height: 36, // Slightly reduced height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                category;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? Colors.orange : Colors.black87,
                            foregroundColor:
                                isSelected ? Colors.black87 : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                          ),
                          child: Text(
                            category
                                .trim()
                                .replaceAll(RegExp(r'[0-9-]'), '')
                                .replaceFirst(RegExp(r'^\.+'), '')
                                .trim(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Book Grid - Increase the space allocation
                Expanded(
                  child: filteredBooks.isEmpty
                      ? Center(
                          child: Text(
                            'No books available in this category',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                0.65, // Adjusted to make cards taller
                            crossAxisSpacing: 10,
                            mainAxisSpacing:
                                15, // Increased spacing between rows
                          ),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetails(bookData: book),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image section
                                    Expanded(
                                      flex: 3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16)),
                                        child: Image.asset(
                                          'assets/${book['coverImage']}',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            print(
                                                'Failed to load image: assets/${book['coverImage']}');
                                            return Image.asset(
                                              'assets/images/bookPlaceHolder.png',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons
                                                        .chrome_reader_mode_outlined,
                                                    size: 50,
                                                    color: Colors.grey[600],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Text information
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book['title'] ?? 'Untitled',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              book['author'] ??
                                                  'Unknown Author',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
