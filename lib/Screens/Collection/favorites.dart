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
    final childAspectRatio =
        screenWidth > 600 ? 0.7 : 0.65; // Adjusted to prevent overflow

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
                  childAspectRatio: childAspectRatio, // Updated aspect ratio
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
      margin: EdgeInsets.zero, // Keep zero margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip
          .antiAlias, // Add this to ensure nothing overflows the card boundaries
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section - kept as is
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Image.asset(
                  'assets/${book['coverImage']}',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/bookPlaceHolder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.chrome_reader_mode_outlined,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    );
                  },
                ),
                // Favorite button - kept as is
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Modified text section with more compact layout
          SizedBox(
            height: 40, // Reduced from 46 to make more room for the button
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 2.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with slightly reduced font size
                  const SizedBox(height: 2), // Reduced spacing
                  Text(
                    book['title'] ?? 'Unknown Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Slightly reduced from 13
                      height: 1.0, // Even more compact
                      color: Colors.black,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1, // Reduced from 2 to 1 to save space
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1), // Reduced spacing
                  // Author with very compact styling
                  
                  ],
              ),
            ),
          ),

          // Read Now button - more compact
          Padding(
            padding:
                const EdgeInsets.fromLTRB(6, 0, 6, 4), // Reduced bottom padding
            child: SizedBox(
              width: double.infinity,
              height: 20, // Reduced from 24
              child: ElevatedButton(
                onPressed: onReadNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 9), // Reduced from 10
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
