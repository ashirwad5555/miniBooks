import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart';
import 'package:mini_books/Theme/mytheme.dart';

import '../../providers/categorySelector_provider.dart';

class CategoryBooksWidget extends ConsumerWidget {
  const CategoryBooksWidget({super.key});

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
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = category;
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                isSelected
                                    ? AppTheme.gradientStart
                                    : Colors.white,
                              ),
                              foregroundColor: WidgetStateProperty.all(
                                isSelected ? Colors.white : Colors.black87,
                              ),
                              elevation: WidgetStateProperty.all(
                                isSelected ? 2 : 0,
                              ),
                              shadowColor: WidgetStateProperty.all(
                                isSelected
                                    ? AppTheme.gradientStart.withOpacity(0.4)
                                    : Colors.transparent,
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 0),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              overlayColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return AppTheme.gradientStart
                                      .withOpacity(0.1);
                                }
                                if (states.contains(WidgetState.hovered)) {
                                  return AppTheme.gradientStart
                                      .withOpacity(0.05);
                                }
                                return null;
                              }),
                            ),
                            child: Text(
                              category
                                  .trim()
                                  .replaceAll(RegExp(r'[0-9-]'), '')
                                  .replaceFirst(RegExp(r'^\.+'), '')
                                  .trim(),
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        borderRadius:
                                            const BorderRadius.vertical(
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
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
