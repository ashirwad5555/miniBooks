import 'package:flutter/material.dart';

class BookCollection {
  final String name;
  final int bookCount;
  final Color color;

  BookCollection({required this.name, required this.bookCount, required this.color});
}

class BookShelfScreen extends StatefulWidget {
  @override
  _BookShelfScreenState createState() => _BookShelfScreenState();
}

class _BookShelfScreenState extends State<BookShelfScreen> {
  List<BookCollection> collections = [
    BookCollection(name: "Fantasy", bookCount: 23, color: Colors.blue),
    BookCollection(name: "Science Fiction", bookCount: 15, color: Colors.green),
    BookCollection(name: "Mystery", bookCount: 18, color: Colors.purple),
  ];

  void _addNewCollection(String name) {
    setState(() {
      collections.add(BookCollection(
        name: name,
        bookCount: 0,
        color: Colors.primaries[collections.length % Colors.primaries.length],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookshelf'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Color(0xFAF1EBF1),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: collections.length + 1, // +1 for the "Add New" button
        itemBuilder: (context, index) {
          if (index == collections.length) {
            return _buildAddNewButton();
          }
          return _buildCollectionCard(collections[index]);
        },
      ),
    );
  }

  Widget _buildCollectionCard(BookCollection collection) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to collection details
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: collection.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.book, color: Colors.white),
              ),
              Spacer(),
              Text(
                collection.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '${collection.bookCount} books',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewButton() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showAddCollectionDialog(),
        child: Center(
          child: Icon(Icons.add, size: 40, color: Colors.grey[400]),
        ),
      ),
    );
  }

  void _showAddCollectionDialog() {
    String newCollectionName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Collection'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Collection Name'),
            onChanged: (value) {
              newCollectionName = value;
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (newCollectionName.isNotEmpty) {
                  _addNewCollection(newCollectionName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}