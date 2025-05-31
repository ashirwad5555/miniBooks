import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart';
import 'package:mini_books/providers/explore_book_provider.dart';
import '../../Theme/mytheme.dart';

class ExploreBody extends ConsumerWidget {
  const ExploreBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        children: [
          // Search box
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                colorScheme.surfaceContainer,
                colorScheme.surfaceContainer.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                color: colorScheme.shadow.withOpacity(0.06),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 3),
                ),
              ],
              ),
              child: TextField(
              controller: searchController,
              textAlignVertical: TextAlignVertical.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
                ),
                hintText: 'Search books, authors, genres...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                child: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                ),
                prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
                ),
                suffixIcon: searchState.searchQuery.isNotEmpty
                  ? AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    splashRadius: 24,
                    onPressed: () {
                      searchController.clear();
                      ref.read(bookSearchProvider.notifier).clearSearch();
                    },
                    ),
                  )
                  : null,
              ),
              cursorColor: colorScheme.primary,
              cursorWidth: 1.5,
              cursorRadius: const Radius.circular(4),
              onChanged: (query) {
                ref.read(bookSearchProvider.notifier).searchBooks(query);
              },
              ),
            ),
            ),

          // Category chip (if category is selected)
          if (searchState.selectedCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Chip(
                      label: Text(
                        'Category: ${searchState.selectedCategory}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      side: BorderSide.none,
                      elevation: 2,
                      shadowColor: colorScheme.shadow.withOpacity(0.5),
                      deleteIcon: Icon(
                        Icons.cancel,
                        size: 18,
                        color: colorScheme.onPrimary.withOpacity(0.8),
                      ),
                      onDeleted: () {
                        ref.read(bookSearchProvider.notifier).resetFilters();
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Results count or categories title
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: showingCategories
                ? Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Book Categories',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${categories.length} categories',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Search Results',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Found ${filteredBooks.length} ${filteredBooks.length == 1 ? "book" : "books"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
          ),

          // Categories grid or Book list
          Expanded(
            child: showingCategories
                ? _buildCategoriesGrid(categories, ref, theme, colorScheme)
                : _buildBooksList(filteredBooks, context, theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(
    List<String> categories,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2, // Adjusted from 1.5 to 1.2 to give more height
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
            theme: theme,
            colorScheme: colorScheme,
            onTap: () {
              ref.read(bookSearchProvider.notifier).selectCategory(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildBooksList(
    List<Map<String, dynamic>> books,
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return books.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No books found',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: books.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
            itemBuilder: (context, index) {
              final book = books[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: 2,
                  shadowColor: colorScheme.shadow.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetails(bookData: book),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'book-cover-${book['id'] ?? book['title']}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.asset(
                                'assets/${book['coverImage']}',
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.book,
                                      size: 40,
                                      color: colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book['title'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book['author'].isEmpty
                                      ? 'Unknown Author'
                                      : book['author'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      constraints: const BoxConstraints(maxWidth: 160),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        book['main_tag'] ?? 'Uncategorized',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final int bookCount;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const CategoryCard({
    super.key,
    required this.title,
    required this.bookCount,
    required this.onTap,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: colorScheme.shadow.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getThemeColorsForCategory(title, colorScheme),
            ),
          ),
          child: Stack(
            children: [
              // Make decorative circles smaller and position them better
              Positioned(
                top: -15,
                right: -15,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -10,
                left: -10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Content - make padding more compact
              Padding(
                padding: const EdgeInsets.all(12.0), // Reduced from 16.0
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Add this to minimize height
                  children: [
                    Icon(
                      _getIconForCategory(title),
                      size: 28, // Reduced from 32
                      color: Colors.black.withOpacity(
                          0.5), // Adjusted opacity for better contrast
                    ),
                    const SizedBox(height: 8), // Reduced from 12
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            14, // Add specific font size to control height
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, // Reduced from 12
                        vertical: 2, // Reduced from 4
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$bookCount ${bookCount == 1 ? 'book' : 'books'}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 10, // Add specific font size
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get theme-based colors for categories
  List<Color> _getThemeColorsForCategory(
      String category, ColorScheme colorScheme) {
    final int hash = category.hashCode;

    switch (hash % 6) {
      case 0:
        return [AppTheme.gradientStart, AppTheme.gradientEnd];
      case 1:
        return [const Color(0xFF7986CB), const Color(0xFF5C6BC0)];
      case 2:
        return [const Color(0xFF66BB6A), const Color(0xFF4CAF50)];
      case 3:
        return [const Color(0xFFFFB74D), const Color(0xFFFFA726)];
      case 4:
        return [const Color(0xFFBA68C8), const Color(0xFF9C27B0)];
      case 5:
        return [const Color(0xFF4FC3F7), const Color(0xFF03A9F4)];
      default:
        return [colorScheme.primary, colorScheme.primaryContainer];
    }
  }

  // Helper method to get icons for different categories
  IconData _getIconForCategory(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('fiction')) return Icons.auto_stories;
    if (categoryLower.contains('science')) return Icons.science;
    if (categoryLower.contains('history')) return Icons.history_edu;
    if (categoryLower.contains('business')) return Icons.business;
    if (categoryLower.contains('health')) return Icons.health_and_safety;
    if (categoryLower.contains('technology')) return Icons.computer;
    if (categoryLower.contains('art')) return Icons.palette;
    if (categoryLower.contains('cooking')) return Icons.restaurant;
    if (categoryLower.contains('travel')) return Icons.flight;
    if (categoryLower.contains('religion')) return Icons.temple_hindu;
    if (categoryLower.contains('philosophy')) return Icons.psychology;
    if (categoryLower.contains('romance')) return Icons.favorite;
    if (categoryLower.contains('mystery')) return Icons.search;
    if (categoryLower.contains('fantasy')) return Icons.castle;
    if (categoryLower.contains('biography')) return Icons.person;

    return Icons.book; // Default icon
  }
}
