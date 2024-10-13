import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Book {
  final String title;
  final String author;
  final String coverUrl;
  final double rating;
  final int views;

  Book({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.rating,
    required this.views,
  });
}

class CategoryExplore extends StatelessWidget {
  final String category;

  CategoryExplore({required this.category});

  // Dummy data for books
  final List<Book> books = [
    Book(
      title: "The Midnight Library",
      author: "Matt Haig",
      coverUrl: "https://example.com/midnight_library.jpg",
      rating: 4.2,
      views: 120000,
    ),
    Book(
      title: "Project Hail Mary",
      author: "Andy Weir",
      coverUrl: "https://example.com/project_hail_mary.jpg",
      rating: 4.5,
      views: 95000,
    ),
    Book(
      title: "The Seven Husbands of Evelyn Hugo",
      author: "Taylor Jenkins Reid",
      coverUrl: "https://example.com/evelyn_hugo.jpg",
      rating: 4.3,
      views: 150000,
    ),
    // Add more dummy books here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildBookCard(books[index]),
                childCount: books.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                book.coverUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.book, size: 50, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRating(book.rating),
                    _buildViews(book.views),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(double rating) {
    return Row(
      children: [
        Icon(Icons.star, size: 16, color: Colors.amber),
        SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildViews(int views) {
    return Row(
      children: [
        Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          '${(views / 1000).toStringAsFixed(1)}k',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}