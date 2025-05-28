import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_books/config/api_config.dart';

class StorageService {
  // Load favorites - first try API, then fall back to local storage
  static Future<List<Map<String, dynamic>>> loadFavoriteBooks() async {
    try {
      // Try to get user email for database lookup
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final email = prefs.getString('userEmail');

      if (isLoggedIn && email != null) {
        // Get favorites from database
        final response = await http
            .get(
              Uri.parse(
                  '${ApiConfig.baseUrl}/api/users/favorites?email=$email'),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data.containsKey('favorites')) {
            // Also save to local storage as backup
            final favoritesList =
                List<Map<String, dynamic>>.from(data['favorites']);
            prefs.setString('favoriteBooks', jsonEncode(favoritesList));
            return favoritesList;
          }
        }
      }

      // Fall back to local storage
      final favoritesJson = prefs.getString('favoriteBooks');
      if (favoritesJson != null) {
        final List<dynamic> decodedJson = jsonDecode(favoritesJson);
        return List<Map<String, dynamic>>.from(decodedJson);
      }

      return [];
    } catch (e) {
      print('Error loading favorites: $e');

      // Fall back to local storage on any error
      try {
        final prefs = await SharedPreferences.getInstance();
        final favoritesJson = prefs.getString('favoriteBooks');
        if (favoritesJson != null) {
          final List<dynamic> decodedJson = jsonDecode(favoritesJson);
          return List<Map<String, dynamic>>.from(decodedJson);
        }
      } catch (e) {
        print('Error loading from local storage: $e');
      }

      return [];
    }
  }

  // Save favorites to both local storage and database
  static Future<void> saveFavoriteBooks(
      List<Map<String, dynamic>> books) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Always save to local storage
      await prefs.setString('favoriteBooks', jsonEncode(books));

      // If logged in, also save to database
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final email = prefs.getString('userEmail');

      if (isLoggedIn && email != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/users/favorites'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'books': books,
          }),
        );
      }
    } catch (e) {
      print('Error saving favorites: $e');
      // Continue silently - at least local storage should work
    }
  }

  // // Save collections
  // static Future<void> saveBookCollections(
  //     List<Map<String, dynamic>> collections) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonCollections = jsonEncode(collections);
  //   await prefs.setString('book_collections', jsonCollections);
  // }

  // Load collections
  static Future<List<Map<String, dynamic>>> loadBookCollections() async {
    try {
      // Try to get user email for database lookup
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final email = prefs.getString('userEmail');

      if (isLoggedIn && email != null) {
        // Get collections from database
        final response = await http
            .get(
              Uri.parse(
                  '${ApiConfig.baseUrl}/api/users/collections?email=$email'),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data.containsKey('collections')) {
            // Also save to local storage as backup
            final collectionsList =
                List<Map<String, dynamic>>.from(data['collections']);
            prefs.setString('book_collections', jsonEncode(collectionsList));
            return collectionsList;
          }
        }
      }

      // Fall back to local storage
      final collectionsJson = prefs.getString('book_collections');
      if (collectionsJson != null) {
        final List<dynamic> decodedJson = jsonDecode(collectionsJson);
        return List<Map<String, dynamic>>.from(decodedJson);
      }

      return [];
    } catch (e) {
      print('Error loading collections: $e');

      // Fall back to local storage on any error
      try {
        final prefs = await SharedPreferences.getInstance();
        final collectionsJson = prefs.getString('book_collections');
        if (collectionsJson != null) {
          final List<dynamic> decodedJson = jsonDecode(collectionsJson);
          return List<Map<String, dynamic>>.from(decodedJson);
        }
      } catch (e) {
        print('Error loading from local storage: $e');
      }

      return [];
    }
  }

  // Save collections to both local storage and database
  static Future<void> saveBookCollections(List<Map<String, dynamic>> collections) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Always save to local storage
      await prefs.setString('book_collections', jsonEncode(collections));
      
      // If logged in, also save to database
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final email = prefs.getString('userEmail');
      
      if (isLoggedIn && email != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/users/collections'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'collections': collections,
          }),
        );
      }
    } catch (e) {
      print('Error saving collections: $e');
      // Continue silently - at least local storage should work
    }
  }
}
