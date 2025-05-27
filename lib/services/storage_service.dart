import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Save favorite books
  static Future<void> saveFavoriteBooks(
      List<Map<String, dynamic>> books) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonBooks = books.map((book) => jsonEncode(book)).toList();
    await prefs.setStringList('favorite_books', jsonBooks);
  }

  // Load favorite books
  static Future<List<Map<String, dynamic>>> loadFavoriteBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonBooks = prefs.getStringList('favorite_books') ?? [];
    return jsonBooks
        .map((jsonBook) => Map<String, dynamic>.from(jsonDecode(jsonBook)))
        .toList();
  }

  // Save collections
  static Future<void> saveBookCollections(
      List<Map<String, dynamic>> collections) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCollections = jsonEncode(collections);
    await prefs.setString('book_collections', jsonCollections);
  }

  // Load collections
  static Future<List<Map<String, dynamic>>> loadBookCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCollections = prefs.getString('book_collections') ?? '[]';
    final List<dynamic> collections = jsonDecode(jsonCollections);
    return collections
        .map((collection) => Map<String, dynamic>.from(collection))
        .toList();
  }
}
