import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/all_books_provider.dart';

class BookList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);

    return Scaffold(
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            leading: Image.network(book['coverUrl'],
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Icon(Icons.chrome_reader_mode_outlined);
              },
            ) ,
            title: Text(book['title']),
            subtitle: Text(book['author']),
            // Add more details as needed
          );
        },
      ),
    );
  }
}