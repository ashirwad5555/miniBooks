import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String contactNo;
  final bool isPremium;
  final String? premiumUntil;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.contactNo = '',
    this.isPremium = false,
    this.premiumUntil,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contactNo: json['contactNo'] ?? '',
      isPremium: json['is_premium'] ?? false,
      premiumUntil: json['premium_until'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contactNo': contactNo,
      'is_premium': isPremium,
      'premium_until': premiumUntil,
      'profile_image': profileImage,
    };
  }

  // Create a User from SharedPreferences data
  static Future<User?> fromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) return null;

    return User(
      id: prefs.getString('userId') ?? '',
      name: prefs.getString('userName') ?? '',
      email: prefs.getString('userEmail') ?? '',
      contactNo: prefs.getString('userPhone') ?? '',
      isPremium: prefs.getBool('isPremium') ?? false,
      profileImage: prefs.getString('profileImage'),
    );
  }
}
