import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart';

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
        backgroundColor: Colors.orange,
      ),
      body: favoriteBooks.isEmpty
          ? const Center(
              child: Text(
                'No favorite books yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with remove button overlay
          Stack(
            children: [
              // Removed the Expanded widget that was causing problems
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                child: SizedBox(
                  height: 120, // Fixed height for consistent card layout
                  width: double.infinity,
                  child: Image.asset(
                    'assets/${book['coverImage']}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print(
                          'Failed to load image: assets/${book['coverImage']}');
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
                top: 5,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: onRemove,
                    tooltip: 'Remove from favorites',
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
          Flexible(
            // Make this section flexible
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] ?? 'Unknown Title',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book['author'] ?? 'Unknown Author'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      book['category'] ?? 'Uncategorized',
                      style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Read Now button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              height: 20,
              child: ElevatedButton(
                onPressed: onReadNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 2),
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
