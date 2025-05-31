import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/providers/books_collection_provider.dart';
import 'package:mini_books/providers/favorites_provider.dart';
import '../../Theme/mytheme.dart';

class BookDetails extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookData;

  const BookDetails({super.key, required this.bookData});

  @override
  ConsumerState<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends ConsumerState<BookDetails> {
  String? selectedCollection;
  String? selectedCollectionName;
  String selectedOption = "";
  String selectedSummaryType = "Text";
  bool isPlaying = false;
  List<String> highlights = [];
  TextEditingController textController = TextEditingController();

  final String sampleText =
      """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.""";

  @override
  Widget build(BuildContext context) {
    final favoriteBooks = ref.watch(favoriteBooksProvider);
    final collections = ref.watch(bookCollectionsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isBookFavorite = favoriteBooks.contains(widget.bookData);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.bookData['title'] ?? 'Book Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors
                .black, // Changed to black instead of colorScheme.onPrimary
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black), // Changed to black
        flexibleSpace: Container(
          decoration: AppTheme.getGradientDecoration(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.playlist_add,
              color: Colors.black, // Changed to black
            ),
            onPressed: () {
              _showPlaylistDialog(context, collections);
            },
          ),
          IconButton(
            icon: Icon(
              isBookFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black, // Changed to black
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
            // Cover Image with gradient overlay
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainer,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Image.asset(
                    'assets/${widget.bookData['coverImage']}',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: colorScheme.surfaceContainer,
                      child: Icon(
                        Icons.book,
                        size: 100,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay for better text readability
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        colorScheme.surface.withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
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
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author
                  if (widget.bookData['author']?.isNotEmpty == true)
                    Text(
                      'By ${widget.bookData['author']}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
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
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                backgroundColor: colorScheme.primary,
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 24),

                  // AI Generated Summaries Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.tertiaryContainer,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Generated Summaries',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                      color: colorScheme.surface,
                      surfaceTintColor: colorScheme.primaryContainer,
                      child: ExpansionTile(
                        iconColor: colorScheme.primary,
                        collapsedIconColor: colorScheme.primary,
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          widget.bookData['aiGeneratedSummary'][index]['title'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.bookData['aiGeneratedSummary'][index]
                                  ['content'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                color: colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Add to Playlist",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: DropdownButton<String>(
                  hint: Text(
                    selectedCollection ?? "Select a playlist",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: selectedCollection,
                  isExpanded: true,
                  underline: Container(),
                  items: collections.map((collection) {
                    return DropdownMenuItem<String>(
                      value: collection.name,
                      child: Text(
                        collection.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCollection = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showCreatePlaylistDialog(context);
                },
                icon: Icon(
                  Icons.add,
                  color: colorScheme.primary,
                ),
                label: Text(
                  "Create New Playlist",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCollection != null) {
                  _addToPlaylist(selectedCollection!);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text("Add to Playlist"),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController playlistController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Create New Playlist",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: TextField(
            controller: playlistController,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: "Enter playlist name",
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text("Create and Add"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, List<BookCollection> collections) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Playlist or Book",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: DropdownButton<String>(
                  hint: Text(
                    selectedCollection ?? "Select a playlist",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: selectedCollection,
                  isExpanded: true,
                  underline: Container(),
                  items: collections.map((collection) {
                    return DropdownMenuItem<String>(
                      value: collection.name,
                      child: Text(
                        collection.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCollection = value;
                    });
                  },
                ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text("Delete Book from Playlist"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCollection != null) {
                  _deletePlaylist(selectedCollection!);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text("Delete Entire Playlist"),
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
