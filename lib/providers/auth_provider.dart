import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http show put;
import 'package:mini_books/config/api_config.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// User state notifier
class UserNotifier extends StateNotifier<Map<String, dynamic>> {
  UserNotifier()
      : super({
          'isAuthenticated': false,
          'userData': {},
          'isLoading': false,
        }) {
    // Check if user is already authenticated when the app starts
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = {...state, 'isLoading': true};
    try {
      // Check if we have a user in ApiService
      if (ApiService.currentUser != null) {
        state = {
          'isAuthenticated': true,
          'userData': ApiService.currentUser!,
          'isLoading': false,
        };
      } else {
        state = {
          'isAuthenticated': false,
          'userData': {},
          'isLoading': false,
        };
      }
    } catch (e) {
      state = {
        'isAuthenticated': false,
        'userData': {},
        'isLoading': false,
        'error': e.toString(),
      };
    }
  }

  // Future<void> login(String email, String password) async {
  //   state = {...state, 'isLoading': true, 'error': null};
  //   try {
  //     final response = await ApiService.login(email, password);
  //     state = {
  //       'isAuthenticated': true,
  //       'userData': response['user'],
  //       'isLoading': false,
  //     };
  //   } catch (e) {
  //     state = {
  //       ...state,
  //       'isLoading': false,
  //       'error': e.toString(),
  //     };
  //     throw e;
  //   }
  // }

  // Future<void> register(Map<String, dynamic> userData) async {
  //   state = {...state, 'isLoading': true, 'error': null};
  //   try {
  //     await ApiService.register(userData);
  //     // After registration, login
  //     await login(userData['email'], userData['password']);
  //   } catch (e) {
  //     state = {
  //       ...state,
  //       'isLoading': false,
  //       'error': e.toString(),
  //     };
  //     throw e;
  //   }
  // }

// Add this method to your ApiService class
  static Future<Map<String, dynamic>?> updateProfile(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/users/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to update profile: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  Future<void> updateSubscription(bool isPremium) async {
    try {
      final response = await ApiService.updateSubscription(isPremium);
      state = {
        ...state,
        'userData': {
          ...state['userData'],
          'is_premium': response['is_premium'],
        }
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    // Update the state with the new profile image URL
    state = {
      ...state,
      'userData': {
        ...state['userData'],
        'profile_image': imageUrl,
      }
    };

    // You could also persist this change to local storage if needed
    await _saveUserData(state['userData']);
  }

  // Helper method to save user data to persistent storage
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(userData));
  }

  void logout() async {
    // Clear the authentication status
    ApiService.logout();
    state = {
      'isAuthenticated': false,
      'userData': {},
      'isLoading': false,
    };
  }

  // Add this method to your UserNotifier class
  void updateUser(Map<String, dynamic> updatedUserData) {
    state = {
      ...state,
      'userData': updatedUserData,
    };
  }
}

// Create provider
final userProvider =
    StateNotifierProvider<UserNotifier, Map<String, dynamic>>((ref) {
  return UserNotifier();
});
