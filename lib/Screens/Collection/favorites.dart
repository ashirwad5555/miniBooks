import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart';
import '../../Theme/mytheme.dart';
import '../../providers/favorites_provider.dart';

class FavoriteBooksScreen extends ConsumerWidget {
  const FavoriteBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteBooks = ref.watch(favoriteBooksProvider);

    // Calculate responsive grid parameters based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = screenWidth > 600 ? 0.75 : 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Books'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        flexibleSpace: Container(
          decoration: AppTheme.getGradientDecoration(),
        ),
      ),
      body: favoriteBooks.isEmpty
          ? const Center(
              child: Text(
                'No favorite books yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: favoriteBooks.length,
                itemBuilder: (context, index) {
                  final book = favoriteBooks[index];
                  return BookCard(
                    book: book,
                    onRemove: () {
                      ref
                          .read(favoriteBooksProvider.notifier)
                          .removeFavoriteBook(book);
                    },
                    onReadNow: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookDetails(bookData: book),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onRemove;
  final VoidCallback onReadNow;

  const BookCard({
    super.key,
    required this.book,
    required this.onRemove,
    required this.onReadNow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // This helps control the height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with remove button overlay - fixed height
          SizedBox(
            height: 110, // Slightly reduced fixed height
            child: Stack(
              fit: StackFit.expand, // Make stack fill the SizedBox
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: SizedBox.expand(
                    child: Image.asset(
                      'assets/${book['coverImage']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/bookPlaceHolder.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                // Add remove button on top-right corner
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onRemove,
                        customBorder: const CircleBorder(),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content section - flexible but constrained
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book title
                  Text(
                    book['title'] ?? 'Unknown Title',
                    style: const TextStyle(
                      fontSize: 12, // Reduced from 14
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1, // Reduced from 2
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3), // Reduced from 4

                  // Author
                  Text(
                    'by ${book['author'] ?? 'Unknown Author'}',
                    style: TextStyle(
                      fontSize: 10, // Reduced from 12
                      color: Colors.grey[600],
                    ),
                    maxLines: 1, // Reduced from 2
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3), // Reduced from 2

                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1, // Reduced padding
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10), // Smaller radius
                    ),
                    child: Text(
                      book['category'] ?? 'Uncategorized',
                      style: TextStyle(
                        fontSize: 8, // Reduced from 10
                        color: Colors.orange[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(), // Pushes button to bottom
                ],
              ),
            ),
          ),

          // Read Now button - fixed at bottom with consistent height
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
            child: SizedBox(
              width: double.infinity,
              height: 24, // Slightly increased for better touch target
              child: ElevatedButton(
                onPressed: onReadNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero, // Remove padding
                  minimumSize: Size.zero, // Remove minimum size constraints
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // Tighter hit testing
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text('Read Now'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
