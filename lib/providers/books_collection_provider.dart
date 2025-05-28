import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// final bookCollectionsProvider =
//     StateNotifierProvider<BookCollectionsNotifier, List<BookCollection>>((ref) {
//   return BookCollectionsNotifier();
// });

class BookCollectionsNotifier extends StateNotifier<List<BookCollection>> {
  BookCollectionsNotifier() : super([]) {
    _initializeState();
  }

  Future<void> _initializeState() async {
    final savedCollections = await StorageService.loadBookCollections();
    state = savedCollections
        .map((collectionMap) => BookCollection.fromJson(collectionMap))
        .toList();
  }

  // Add this method to refresh collections from the server
  Future<void> refreshCollections() async {
    final savedCollections = await StorageService.loadBookCollections();
    state = savedCollections
        .map((collectionMap) => BookCollection.fromJson(collectionMap))
        .toList();
  }

  void addBookToCollection(
      BookCollection collection, Map<String, dynamic> book) {
    state = [
      for (final col in state)
        if (col.name == collection.name)
          col.copyWith(books: [...col.books, book])
        else
          col
    ];
    _saveState();
  }

  void removeBookFromCollection(
      BookCollection collection, Map<String, dynamic> book) {
    state = [
      for (final col in state)
        if (col.name == collection.name)
          col.copyWith(
              books:
                  col.books.where((b) => b['title'] != book['title']).toList())
        else
          col
    ];
    _saveState();
  }

  void createNewCollection(String collectionName) {
    final newCollection = BookCollection(name: collectionName, books: []);
    state = [...state, newCollection];
    _saveState();
  }

  void deleteCollection(String collectionName) {
    state = state.where((col) => col.name != collectionName).toList();
    _saveState();
  }

  void _saveState() {
    final collectionsJson =
        state.map((collection) => collection.toJson()).toList();
    StorageService.saveBookCollections(collectionsJson);
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'books': books,
    };
  }

  static BookCollection fromJson(Map<String, dynamic> json) {
    return BookCollection(
      name: json['name'],
      books: (json['books'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }
}

final bookCollectionsProvider =
    StateNotifierProvider<BookCollectionsNotifier, List<BookCollection>>(
  (ref) => BookCollectionsNotifier(),
);
