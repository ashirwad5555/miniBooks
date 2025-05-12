import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/providers/books_collection_provider.dart';
import 'package:mini_books/providers/favorites_provider.dart';

class BookDetails extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookData;

  const BookDetails({Key? key, required this.bookData}) : super(key: key);

  @override
  ConsumerState<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends ConsumerState<BookDetails> {
  // Now you can use ref throughout your code
  String? selectedCollection;
  String? selectedCollectionName; // Default playlist label
  String selectedOption = "";
  String selectedSummaryType = "Text"; // Default summary type
  bool isPlaying = false;
  List<String> highlights = [];
  TextEditingController textController = TextEditingController();

  final String sampleText =
      """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.""";

  @override
  Widget build(BuildContext context) {
    final favoriteBooks = ref.watch(favoriteBooksProvider);
    final collections = ref.watch(bookCollectionsProvider);

    final isBookFavorite = favoriteBooks.contains(widget.bookData);
    // Define a color palette
    const Color primaryColor = Color(0xFF0D47A1); // Deep Blue
    const Color accentColor = Color(0xFF42A5F5); // Light Blue
    const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
    const Color textColor = Color(0xFF212121); // Dark Grey

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.bookData['title'] ?? 'Book Details',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              _showPlaylistDialog(context, collections);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.delete),
          //   onPressed: () {
          //     _showDeleteDialog(context, collections);
          //   },
          // ),
          IconButton(
            icon: Icon(
              isBookFavorite ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () {
              final notifier = ref.read(favoriteBooksProvider.notifier);
              if (isBookFavorite) {
                notifier.removeFavoriteBook(widget.bookData);
              } else {
                notifier.addFavoriteBook(widget.bookData);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Container(
              color: Colors.grey[200],
              child: Image.asset(
                'assets/${widget.bookData['coverImage']}',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.book,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.bookData['title'] ?? 'Unknown Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author
                  if (widget.bookData['author']?.isNotEmpty == true)
                    Text(
                      'By ${widget.bookData['author']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: textColor,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Category Tags
                  if (widget.bookData['category Tags'] != null &&
                      (widget.bookData['category Tags'] as List).isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (widget.bookData['category Tags'] as List)
                          .map((tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                backgroundColor: accentColor,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 24),

                  // AI Generated Summaries Header
                  const Text(
                    'AI Generated Summaries',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // AI Generated Summaries
                  ...List.generate(
                    (widget.bookData['aiGeneratedSummary'] as List).length,
                    (index) => Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      child: ExpansionTile(
                        iconColor: primaryColor,
                        title: Text(
                          widget.bookData['aiGeneratedSummary'][index]['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              widget.bookData['aiGeneratedSummary'][index]
                                  ['content'],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistDialog(
      BuildContext context, List<BookCollection> collections) {
    final bookCollections = ref.watch(bookCollectionsProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add to Playlist"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text(
                  selectedCollection ?? "Select a playlist",
                ),
                value: selectedCollection,
                items: collections.map((collection) {
                  return DropdownMenuItem<String>(
                    value: collection.name,
                    child: Text(collection.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCollection = newValue;
                    // selectedPlaylistName = (value).toString();
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showCreatePlaylistDialog(context);
                },
                child: Text("Create New Playlist"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCollection != null) {
                  _addToPlaylist(selectedCollection!);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Add to Playlist"),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController playlistController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New Playlist"),
          content: TextField(
            controller: playlistController,
            decoration: InputDecoration(
              hintText: "Enter playlist name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (playlistController.text.isNotEmpty) {
                  ref
                      .read(bookCollectionsProvider.notifier)
                      .createNewCollection(playlistController.text);
                  _addToPlaylist(playlistController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Create and Add"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, List<BookCollection> collections) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Playlist or Book"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text(
                  selectedCollection ?? "Select a playlist",
                ),
                value: selectedCollection,
                items: collections.map((collection) {
                  return DropdownMenuItem<String>(
                    value: collection.name,
                    child: Text(collection.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCollection = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (selectedCollection != null) {
                  _deleteBookFromPlaylist(selectedCollection!);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Delete Book from Playlist"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCollection != null) {
                  _deletePlaylist(selectedCollection!);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Delete Entire Playlist"),
            ),
          ],
        );
      },
    );
  }

  void _addToPlaylist(String collectionName) {
    final collection = ref
        .read(bookCollectionsProvider)
        .firstWhere((col) => col.name == collectionName);
    ref
        .read(bookCollectionsProvider.notifier)
        .addBookToCollection(collection, widget.bookData);
  }

  void _deleteBookFromPlaylist(String collectionName) {
    final collection = ref
        .read(bookCollectionsProvider)
        .firstWhere((col) => col.name == collectionName);
    ref
        .read(bookCollectionsProvider.notifier)
        .removeBookFromCollection(collection, widget.bookData);
  }

  void _deletePlaylist(String collectionName) {
    ref.read(bookCollectionsProvider.notifier).deleteCollection(collectionName);
  }
}
