import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_books/config/api_config.dart';

class ApiService {
  // Set to false to use actual backend instead of offline mode
  static const bool _useOfflineMode = false;

  // In-memory storage for currently logged in user
  static Map<String, dynamic>? _currentUser;

  // Simple getter for current user
  static Map<String, dynamic>? get currentUser => _currentUser;

  // // Register a new user
  // static Future<Map<String, dynamic>> register(
  //     Map<String, dynamic> userData) async {
  //   if (_useOfflineMode) {
  //     // Offline mode implementation
  //     await Future.delayed(Duration(seconds: 1));
  //     // Store mock user data in offline database
  //     _offlineUsers[userData['email']] = {
  //       ...userData,
  //       'id': 'user_${_offlineUsers.length + 1}',
  //       'password': userData['password'], // In real app, always hash passwords
  //       'is_premium': false,
  //     };

  //     // Return fake successful response
  //     return {
  //       'message': 'User registered successfully',
  //       'userId': _offlineUsers[userData['email']]?['id']
  //     };
  //   }

  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse('${ApiConfig.baseUrl}/api/users/register'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode(userData),
  //         )
  //         .timeout(Duration(seconds: 10));

  //     final data = jsonDecode(response.body);
  //     if (response.statusCode == 201) {
  //       return data;
  //     } else {
  //       throw Exception(data['error'] ?? 'Registration failed');
  //     }
  //   } catch (e) {
  //     if (e is Exception) {
  //       rethrow;
  //     }
  //     throw Exception('Network error: ${e.toString()}');
  //   }
  // }

  // // Update the login method to ensure the user ID is handled correctly
  // static Future<Map<String, dynamic>> login(
  //     String email, String password) async {
  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse('${ApiConfig.baseUrl}/api/users/login'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({'email': email, 'password': password}),
  //         )
  //         .timeout(const Duration(seconds: 10));

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);

  //       // Extract user data from the response
  //       // The response structure may be different than expected
  //       final Map<String, dynamic> data =
  //           responseData is List ? responseData[0] : responseData;

  //       final Map<String, dynamic> userData = data['user'] ?? {};

  //       // Store user in memory - ensure ID is handled as a string
  //       _currentUser = userData;

  //       return data;
  //     } else {
  //       final data = jsonDecode(response.body);
  //       throw Exception(data['error'] ?? 'Login failed');
  //     }
  //   } catch (e) {
  //     if (e is Exception) {
  //       rethrow;
  //     }
  //     throw Exception('Network error: ${e.toString()}');
  //   }
  // }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String email) async {
    if (_useOfflineMode) {
      // Offline mode implementation
      await Future.delayed(const Duration(seconds: 1));
      // Return current user if logged in
      if (_currentUser != null) {
        return _currentUser!;
      } else {
        throw Exception('Not authenticated');
      }
    }

    try {
      // FIXED: Don't use null-aware operator on a non-nullable parameter
      final String userEmail =
          email.isNotEmpty ? email : _currentUser?['email'] ?? '';
      if (userEmail.isEmpty) {
        throw Exception('Email is required to fetch profile');
      }

      final response = await http
          .get(
            Uri.parse(
                '${ApiConfig.baseUrl}/api/users/profile?email=$userEmail'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data; // Update in-memory user data
        return data;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to get profile');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update user profile - matches the Flask route
  static Future<Map<String, dynamic>?> updateProfile(
      Map<String, dynamic> userData) async {
    if (_useOfflineMode) {
      // Offline mode implementation
      await Future.delayed(const Duration(seconds: 1));
      // Update in-memory user data
      if (_currentUser != null) {
        // Add null check
        _currentUser = {
          ..._currentUser!,
          ...userData,
        };

        // Also update in offline database
        if (_offlineUsers.containsKey(_currentUser!['email'])) {
          _offlineUsers[_currentUser!['email']] = {
            ..._offlineUsers[_currentUser!['email']]!,
            ...userData,
          };
        }
      }

      return {'message': 'Profile updated successfully'};
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/users/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update current user if available
        if (_currentUser != null) {
          _currentUser = {
            ..._currentUser!,
            ...userData,
          };
        }

        return data;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Update user password
  static Future<Map<String, dynamic>> updatePassword(
      String email, String currentPassword, String newPassword) async {
    if (_useOfflineMode) {
      // Offline mode implementation
      await Future.delayed(const Duration(seconds: 1));
      return {'message': 'Password updated successfully'};
    }

    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/users/update-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to update password');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update subscription status
  // Update subscription status in the backend
  static Future<bool> updateSubscriptionStatus(
      String email, bool isPremium) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/subscription'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'is_premium': isPremium,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update subscription: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }

  // Logout user
  static void logout() {
    _currentUser = null;
  }

  // // Upload profile image
  // static Future<Map<String, dynamic>> uploadProfileImage(File image) async {
  //   if (_useOfflineMode) {
  //     // Offline mode implementation
  //     await Future.delayed(Duration(seconds: 1));
  //     // Simulate successful image upload by returning a fake image URL
  //     final fakeImageUrl =
  //         'https://example.com/images/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

  //     // Update the user's profile image in memory
  //     _currentUser = {
  //       ..._currentUser!,
  //       'profile_image': fakeImageUrl,
  //     };

  //     // Also update in offline database if the user exists
  //     if (_offlineUsers.containsKey(_currentUser!['email'])) {
  //       _offlineUsers[_currentUser!['email']] = {
  //         ..._offlineUsers[_currentUser!['email']]!,
  //         'profile_image': fakeImageUrl,
  //       };
  //     }

  //     return {
  //       'message': 'Profile image uploaded successfully',
  //       'profile_image': fakeImageUrl,
  //     };
  //   }

  //   try {
  //     final email = _currentUser?['email'];
  //     if (email == null) {
  //       throw Exception('User not authenticated');
  //     }

  //     // Create a multipart request
  //     final request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${ApiConfig.baseUrl}/api/users/upload-profile-image'),
  //     );

  //     // Add the email field
  //     request.fields['email'] = email;

  //     // Add the file
  //     final fileStream = http.ByteStream(image.openRead());
  //     final fileLength = await image.length();

  //     final multipartFile = http.MultipartFile(
  //       'profile_image',
  //       fileStream,
  //       fileLength,
  //       filename: 'profile_image.jpg',
  //       contentType: MediaType('image', 'jpeg'),
  //     );

  //     request.files.add(multipartFile);

  //     // Send the request
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     // Check if successful
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       // Update current user if available
  //       if (_currentUser != null && data.containsKey('profile_image')) {
  //         _currentUser = {
  //           ..._currentUser!,
  //           'profile_image': data['profile_image'],
  //         };
  //       }

  //       return data;
  //     } else {
  //       final data = jsonDecode(response.body);
  //       throw Exception(data['error'] ?? 'Failed to upload image');
  //     }
  //   } catch (e) {
  //     throw Exception('Error uploading image: $e');
  //   }
  // }

  // Update profile image with base64 approach
  static Future<Map<String, dynamic>?> uploadProfileImage(
      String email, String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/upload-profile-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // In-memory database for offline mode
  static final Map<String, Map<String, dynamic>> _offlineUsers = {
    'test@example.com': {
      'id': 'user_1',
      'name': 'Test User',
      'email': 'test@example.com',
      'password': 'password123',
      'contactNo': '9876543210',
      'is_premium': false,
    }
  };
}
