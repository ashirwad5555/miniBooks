import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/default.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../providers/books_collection_provider.dart';
import '../../providers/favorites_provider.dart';


class BookSummaryPage extends ConsumerStatefulWidget {
  // final String bookTitle;
  // final String author;
  // final int views;
  // final double rating;
  //
  // BookSummaryPage({
  //   required this.bookTitle,
  //   required this.author,
  //   required this.views,
  //   required this.rating,
  // });

  final Map<String, dynamic> book;

  const BookSummaryPage({Key? key, required this.book}) : super(key: key);

  @override
  ConsumerState<BookSummaryPage> createState() => _BookSummaryPageState();
}

class _BookSummaryPageState extends ConsumerState<BookSummaryPage> {

  String? selectedCollection;
  String? selectedCollectionName ; // Default playlist label
  String selectedOption = "";
  String selectedSummaryType = "Text"; // Default summary type
  bool isPlaying = false;
  List<String> highlights = [];
  TextEditingController textController = TextEditingController();

  // // Add these to your existing state variables
  // List<Highlight> highlights1 = [];
  final String sampleText = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.""";



  final List<Color> highlightColors = [
    Colors.yellow.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.pink.withOpacity(0.3),
  ];

  final Map<String, Widget> summaryTypes = {
    'Text': Icon(Icons.text_fields),
    'AI': Icon(Icons.psychology),
    'YouTube': Icon(Icons.play_circle_filled),
    'Mindmap': Icon(Icons.account_tree),
  };


  @override
  Widget build(BuildContext context) {
    final favoriteBooks = ref.watch(favoriteBooksProvider);
    final collections = ref.watch(bookCollectionsProvider);

    final isBookFavorite = favoriteBooks.contains(widget.book);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title']),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              _showPlaylistDialog(context, collections);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context, collections);
            },
          ),
          IconButton(
            icon: Icon(
              isBookFavorite ? Icons.bookmark : Icons.bookmark_border,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Details (unchanged)
            Center(
              child: Column(
                children: [
                  Text(
                    widget.book['title'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "by ${widget.book['author']}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.grey, size: 18),
                      SizedBox(width: 5),
                      Text("${widget.book['views']} views",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      SizedBox(width: 15),
                      Icon(Icons.star, color: Colors.yellow[700], size: 18),
                      SizedBox(width: 5),
                      Text("${widget.book['rating']}",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Option buttons (Listen, Read, Save)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // _optionButton("Listen", Icons.headphones),
                _optionButton("Read", Icons.book),
                // _optionButton("Save", Icons.bookmark),
              ],
            ),
            SizedBox(height: 20),

            // Summary Type Selector
            if (selectedOption == "Read")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Summary Type",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: summaryTypes.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Row(
                              children: [
                                entry.value,
                                SizedBox(width: 5),
                                Text(entry.key),
                              ],
                            ),
                            selected: selectedSummaryType == entry.key,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedSummaryType = entry.key;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.orange,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

            // Conditionally rendering content based on selected option and summary type
            if (selectedOption == "Listen") _buildAudioPlayer(),
            if (selectedOption == "Read") _buildSummaryContent(),


            // Highlights Section
            if (highlights.isNotEmpty) _buildHighlightsSection(),
          ],
        ),
      ),
    );
  }

  void _showPlaylistDialog(BuildContext context, List<BookCollection> collections) {
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
                  ref.read(bookCollectionsProvider.notifier).createNewCollection(playlistController.text);
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

  void _showDeleteDialog(BuildContext context, List<BookCollection> collections) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Playlist or Book"),
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

  Widget _buildTextSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Text Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 10),
          SelectableText(
            widget.book['textSummary'],
            style: TextStyle(fontSize: 16, height: 1.5),
            onSelectionChanged: (selection, cause) {
              if (selection != null &&
                  selection.baseOffset != selection.extentOffset) {
                _showHighlightDialog(selection);

              }
            },
          ),
        ],
      ),
    );
  }


  Widget _buildAISummary() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 10),
          Text(
            widget.book['aiGeneratedSummary'],
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 10),
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
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 10),
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
          title: Text("Save Highlight"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Selected text:"),
              SizedBox(height: 10),
              Text(
                textController.text.substring(start, end),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Save"),
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


  Widget _buildHighlightsSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Highlights",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(Icons.format_quote, color: Colors.orange),
                  title: Text(highlights[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
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

  // Function to build audio player
  Widget _buildAudioPlayer() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        children: [
          Text(
            "Audio Player",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: Colors.orange,
            size: 60,
          ),
          SizedBox(height: 10),
          Text(
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

  Widget _optionButton(String title, IconData icon) {
    bool isActive = selectedOption == title;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          selectedOption = title;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.orange : Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Function to build reading text
  Widget _buildReadingText() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reading",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Once upon a time in a faraway land...",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(height: 10),
          Text(
            "This is where the full text of the book will be displayed for reading.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class YouTubeVideoWidget extends StatefulWidget {
  final String youtubeUrl;

  const YouTubeVideoWidget({Key? key, required this.youtubeUrl}) : super(key: key);

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
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        SizedBox(height: 10),
        Container(
          height: 200,
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: ProgressBarColors(
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