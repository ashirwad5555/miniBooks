
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../providers/books_collection_provider.dart';
import '../../providers/favorites_provider.dart';

class BookSummaryPage1 extends ConsumerStatefulWidget {
  final Map<String, dynamic> book;

  const BookSummaryPage1({super.key, required this.book});

  @override
  ConsumerState<BookSummaryPage1> createState() => _BookSummaryPageState();
}

class _BookSummaryPageState extends ConsumerState<BookSummaryPage1> {
  String? selectedCollection;
  String? selectedCollectionName;
  String selectedOption = "";
  String selectedSummaryType = "Text";
  bool isPlaying = false;
  List<String> highlights = [];
  TextEditingController textController = TextEditingController();

  final String sampleText = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.""";

  final List<Color> highlightColors = [
    Colors.yellow.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.pink.withOpacity(0.3),
  ];

  final Map<String, Widget> summaryTypes = {
    'Text': const Icon(Icons.text_fields, color: Colors.white),
    'AI': const Icon(Icons.psychology, color: Colors.white),
    'YouTube': const Icon(Icons.play_circle_filled, color: Colors.white),
    'Mindmap': const Icon(Icons.account_tree, color: Colors.white),
  };

  @override
  Widget build(BuildContext context) {
    final favoriteBooks = ref.watch(favoriteBooksProvider);
    final collections = ref.watch(bookCollectionsProvider);
    final isBookFavorite = favoriteBooks.contains(widget.book);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.book['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 8.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Book Cover Image
                  Image.network(
                    widget.book['coverUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.orange.shade400,
                              Colors.deepOrange.shade600,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.chrome_reader_mode_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                  // Gradient Overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                  // Top Gradient for status bar area
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                  ),
                ],
              ),
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.playlist_add,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                onPressed: () => _showPlaylistDialog(context, collections),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                onPressed: () => _showDeleteDialog(context, collections),
              ),
              IconButton(
                icon: Icon(
                  isBookFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                onPressed: () {
                  final notifier = ref.read(favoriteBooksProvider.notifier);
                  if (isBookFavorite) {
                    notifier.removeFavoriteBook(widget.book);
                  } else {
                    notifier.addFavoriteBook(widget.book);
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "by ${widget.book['author']}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatCard(
                                Icons.remove_red_eye,
                                "${widget.book['views']}",
                                "Views",
                              ),
                              const SizedBox(width: 24),
                              _buildStatCard(
                                Icons.star,
                                "${widget.book['rating']}",
                                "Rating",
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Option buttons with new design
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildOptionButton("Read", Icons.book),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Type Selector with new design
                  if (selectedOption == "Read")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Summary Type",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 45,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: summaryTypes.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildSummaryTypeChip(entry.key, entry.value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Content based on selection
                  if (selectedOption == "Listen") _buildAudioPlayer(),
                  if (selectedOption == "Read") _buildSummaryContent(),

                  // Highlights Section with new design
                  if (highlights.isNotEmpty) _buildHighlightsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.grey[700], size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTypeChip(String type, Widget icon) {
    bool isSelected = selectedSummaryType == type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedSummaryType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            )
                : null,
            color: isSelected ? null : Colors.grey[300],
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String title, IconData icon) {
    bool isActive = selectedOption == title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedOption = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            )
                : null,
            color: isActive ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[800],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[800],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 10,),
              isActive ? const SizedBox(width: 10,) : Icon(Icons.arrow_forward_ios,color: Colors.grey[800],)
            ],
          ),
        ),
      ),
    );
  }

  // Keep existing method implementations but update their UI components
  Widget _buildTextSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.format_quote, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Text(
                "Text Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            widget.book['textSummary'],
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
            onSelectionChanged: (selection, cause) {
              if (selection.baseOffset != selection.extentOffset) {
                _showHighlightDialog(selection);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "Audio Player",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: Colors.orange,
            size: 60,
          ),
          const SizedBox(height: 10),
          const Text(
            "Playing: Chapter 1",
            style: TextStyle(color: Colors.white),
          ),
          Slider(
            value: 0.5,
            onChanged: (value) {
              // Handle audio slider changes
            },
            activeColor: Colors.orange,
            inactiveColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    switch (selectedSummaryType) {
      case 'Text':
        return _buildTextSummary();
      case 'AI':
        return _buildAISummary();
      case 'YouTube':
        return _buildYouTubeSummary();
      case 'Mindmap':
        return _buildMindmapSummary();
      default:
        return _buildTextSummary();
    }
  }

  Widget _buildAISummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                "AI Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.book['aiGeneratedSummary'],
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [

              SizedBox(width: 10),
              Text(
                "YouTube Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Container(
          //   height: 200,
          //   color: Colors.grey[300],
          //   child: Center(
          //     child: Icon(
          //       Icons.play_circle_outline,
          //       size: 50,
          //       color: Colors.red,
          //     ),
          //   ),
          // ),
          YouTubeVideoWidget(youtubeUrl: widget.book['youtubeSummaryLink']),
        ],
      ),
    );
  }

  Widget _buildMindmapSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_tree, color: Colors.green),
              SizedBox(width: 10),
              Text(
                "Mindmap Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
              child: Text(widget.book['mindmapSummary']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Highlights",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.format_quote, color: Colors.orange),
                  title: Text(highlights[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        highlights.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

// Keep all other existing methods but update their UI components similarly
// The rest of the implementation remains the same...

  void _showHighlightDialog(TextSelection selection) {
    int start = selection.baseOffset;
    int end = selection.extentOffset;

    // Ensure the selection indices are within bounds
    if (start < 0 || end > textController.text.length || start > end) {
      return; // Avoid the RangeError if the selection is invalid
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Highlight"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Selected text:"),
              const SizedBox(height: 10),
              Text(
                textController.text.substring(start, end),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  highlights.add(textController.text.substring(start, end));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistDialog(BuildContext context, List<BookCollection> collections) {
    final bookCollections = ref.watch(bookCollectionsProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add to Playlist"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text(selectedCollection ?? "Select a playlist",),
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
                child: const Text("Create New Playlist"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCollection != null) {
                  _addToPlaylist(selectedCollection!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add to Playlist"),
            ),

          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, List<BookCollection> collections) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Playlist or Book"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text(selectedCollection ?? "Select a playlist",),
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
              child: const Text("Delete Book from Playlist"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCollection != null) {
                  _deletePlaylist(selectedCollection!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Delete Entire Playlist"),
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
          title: const Text("Create New Playlist"),
          content: TextField(
            controller: playlistController,
            decoration: const InputDecoration(
              hintText: "Enter playlist name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (playlistController.text.isNotEmpty) {
                  ref.read(bookCollectionsProvider.notifier).createNewCollection(playlistController.text);
                  _addToPlaylist(playlistController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Create and Add"),
            ),
          ],
        );
      },
    );
  }

  void _addToPlaylist(String collectionName) {
    final collection = ref.read(bookCollectionsProvider).firstWhere((col) => col.name == collectionName);
    ref.read(bookCollectionsProvider.notifier).addBookToCollection(collection, widget.book);
  }

  void _deleteBookFromPlaylist(String collectionName) {
    final collection = ref.read(bookCollectionsProvider).firstWhere((col) => col.name == collectionName);
    ref.read(bookCollectionsProvider.notifier).removeBookFromCollection(collection, widget.book);
  }

  void _deletePlaylist(String collectionName) {
    ref.read(bookCollectionsProvider.notifier).deleteCollection(collectionName);
  }

}



class YouTubeVideoWidget extends StatefulWidget {
  final String youtubeUrl;

  const YouTubeVideoWidget({super.key, required this.youtubeUrl});

  @override
  _YouTubeVideoWidgetState createState() => _YouTubeVideoWidgetState();
}

class _YouTubeVideoWidgetState extends State<YouTubeVideoWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}