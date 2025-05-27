import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart'; // Use BookDetails instead
import '../../providers/books_collection_provider.dart';

class PlaylistBooksScreen extends ConsumerWidget {
  final BookCollection collection;
  const PlaylistBooksScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          collection.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFff9a9e), Color(0xFFfad0c4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: () => showDeletePlaylistDialog(context, ref),
          ),
        ],
      ),
      body: collection.books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'No books in this playlist.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65, // Adjusted to make cards taller
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                ),
                itemCount: collection.books.length,
                itemBuilder: (context, index) {
                  final book = collection.books[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => BookDetails(bookData: book),
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
                            child: Stack(
                              children: [
                                // Book cover
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
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
                                              Icons.chrome_reader_mode_outlined,
                                              size: 50,
                                              color: Colors.grey[600],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // Delete button on top right
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => showDeleteBookDialog(
                                          context, ref, book),
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
                                          Icons.delete_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Text information
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    book['author'] ?? 'Unknown Author',
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
    );
  }

  // Keep the existing dialog methods
  void showDeleteBookDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Book',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to remove "${book['title']}" from the playlist "${collection.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(bookCollectionsProvider.notifier)
                    .removeBookFromCollection(collection, book);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void showDeletePlaylistDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Playlist',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete the entire playlist "${collection.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(bookCollectionsProvider.notifier)
                    .deleteCollection(collection.name);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
