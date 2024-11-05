import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/temp/test_book_sammaryPage.dart';

import '../../providers/favorites_provider.dart';
import '../BookSummaryPage/book_summary_page.dart';

class FavoriteBooksScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteBooks = ref.watch(favoriteBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Books'),
        backgroundColor: Colors.orange,
      ),
      body: favoriteBooks.isEmpty
          ? Center(
        child: Text(
          'No favorite books yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: favoriteBooks.length,
        itemBuilder: (context, index) {
          final book = favoriteBooks[index];
          return BookCard(
            book: book,
            onRemove: () {
              ref.read(favoriteBooksProvider.notifier).removeFavoriteBook(book);
            },
            onReadNow: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookSummaryPage1(book: book),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onRemove;
  final VoidCallback onReadNow;

  const BookCard({
    Key? key,
    required this.book,
    required this.onRemove,
    required this.onReadNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                book['coverUrl'] ?? 'https://via.placeholder.com/150x200',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'] ?? 'Unknown Title',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'by ${book['author'] ?? 'Unknown Author'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    book['category'] ?? 'Uncategorized',
                    style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
          ButtonBar(
            buttonPadding: EdgeInsets.zero,
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: Text('Read Now', style: TextStyle(fontSize: 12)),
                onPressed: onReadNow,
              ),
              TextButton(
                child: Text('Remove', style: TextStyle(fontSize: 12)),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}