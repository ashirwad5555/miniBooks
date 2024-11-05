import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookCollectionsProvider = StateNotifierProvider<BookCollectionsNotifier, List<BookCollection>>((ref) {
  return BookCollectionsNotifier();
});

class BookCollectionsNotifier extends StateNotifier<List<BookCollection>> {
  BookCollectionsNotifier() : super([]);

  void addBookToCollection(BookCollection collection, Map<String, dynamic> book) {
    state = [
      for (final col in state)
        if (col.name == collection.name)
          col.copyWith(books: [...col.books, book])
        else
          col
    ];
  }

  void removeBookFromCollection(BookCollection collection, Map<String, dynamic> book) {
    state = [
      for (final col in state)
        if (col.name == collection.name)
          col.copyWith(books: col.books.where((b) => b['title'] != book['title']).toList())
        else
          col
    ];
  }

  void createNewCollection(String collectionName) {
    final newCollection = BookCollection(name: collectionName, books: []);
    state = [...state, newCollection];
  }

  void deleteCollection(String collectionName) {
    state = state.where((col) => col.name != collectionName).toList();
  }
}

class BookCollection {
  final String name;
  final List<Map<String, dynamic>> books;

  BookCollection({required this.name, required this.books});

  BookCollection copyWith({String? name, List<Map<String, dynamic>>? books}) {
    return BookCollection(
      name: name ?? this.name,
      books: books ?? this.books,
    );
  }
}
