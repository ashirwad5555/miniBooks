import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Replace provider with riverpod
import 'package:image_picker/image_picker.dart';
import 'package:mini_books/Screens/Auth/simple_auth_screen.dart';
import 'package:mini_books/config/api_config.dart' show ApiConfig;
import 'package:mini_books/providers/auth_provider.dart'
    show UserNotifier, userProvider;
import 'package:mini_books/providers/books_collection_provider.dart';
import 'package:mini_books/providers/favorites_provider.dart';
import 'package:mini_books/services/api_service.dart' show ApiService;
import 'package:shared_preferences/shared_preferences.dart';
import '../Subscription/subscription_page.dart';
import 'dart:convert'; // Add this import at the top of the file

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;

  File? _profileImage;
  String? _imageUrl;

  // User data
  Map<String, dynamic> userData = {
    'employeeId': '',
    'name': '',
    'email': '',
    'contactNo': '',
    'is_premium': false,
    'premium_until': null,
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First try to load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        // Get image URL and ensure it's properly formatted
        String? profileImage = prefs.getString('profileImage');
        if (profileImage != null && !profileImage.startsWith('http')) {
          profileImage = '${ApiConfig.baseUrl}$profileImage';
        }

        setState(() {
          userData = {
            '_id': prefs.getString('userId') ?? '',
            'name': prefs.getString('userName') ?? '',
            'email': prefs.getString('userEmail') ?? '',
            'contactNo': prefs.getString('userPhone') ?? '',
            'is_premium': prefs.getBool('isPremium') ?? false,
            'premium_until': null, // This isn't stored in preferences
            'profile_image': profileImage,
          };
          _imageUrl = profileImage;
          _initControllers();
          _isLoading = false;
        });
      } else {
        // Fall back to provider if not in SharedPreferences
        final userState = ref.read(userProvider);
        if (userState['isAuthenticated']) {
          final profile = userState['userData'];
          setState(() {
            userData = profile;
            _imageUrl = profile['profile_image'];
            _initControllers();
            _isLoading = false;
          });
        } else {
          // Fetch fresh data if not in state
          final profile = await ApiService.getUserProfile();
          setState(() {
            userData = profile;
            _imageUrl = profile['profile_image'];
            _initControllers();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
      );
    }
  }

  void _initControllers() {
    _nameController.text = userData['name'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _contactController.text = userData['contactNo'] ?? '';
  }

  // Add this method to handle image picking
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Reduce image size for faster upload
      maxWidth: 500,
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });

      try {
        // Show loading indicator
        setState(() {
          _isLoading = true;
        });

        // Convert image to base64
        String base64Image = await imageToBase64(pickedImage.path);

        // Call API service to upload the image
        final result =
            await ApiService.uploadProfileImage(userData['email'], base64Image);

        if (result != null && result.containsKey('profile_image')) {
          final String imageUrl = result['profile_image'];

          // Make sure the URL is properly formatted with the base URL
          final String fullImageUrl = imageUrl.startsWith('http')
              ? imageUrl
              : '${ApiConfig.baseUrl}$imageUrl';

          setState(() {
            _imageUrl = fullImageUrl;
            userData['profile_image'] = fullImageUrl;
          });

          // Update SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profileImage', fullImageUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        } else {
          throw Exception("Invalid response from server");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
      } finally {
        // Hide loading indicator
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add this helper function to convert image to base64
  Future<String> imageToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  // Add this to any screen where you want to allow logout
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Clear local collections (optional)
    await prefs.remove('book_collections');
    await prefs.remove('favoriteBooks');

    // Reset the providers
    ref.read(favoriteBooksProvider.notifier).refreshFavorites();
    ref.read(bookCollectionsProvider.notifier).refreshCollections();


    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SimpleAuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    final userState = ref.watch(userProvider);
    final isAuthenticated = userState['isAuthenticated'];

    // If not authenticated, redirect to login
    if (!isAuthenticated && !_isLoading) {
      // You may want to navigate to login screen here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Navigator.of(context).pushReplacementNamed('/login');
      });
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('User Profile'),
            backgroundColor: Colors.orange,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit),
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      if (_formKey.currentState!.validate()) {
                        _saveProfile();
                      }
                    }
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
          backgroundColor: const Color(0xF1FFD8BB),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 70,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : (_imageUrl != null &&
                                              _imageUrl!.isNotEmpty
                                          ? NetworkImage(_imageUrl!
                                                  .startsWith('http')
                                              ? _imageUrl!
                                              : '${ApiConfig.baseUrl}${_imageUrl!}')
                                          : const NetworkImage(
                                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_3PTTNMSlcllsWjg0uRZs-JUJfS2LmZAwwA&s")),
                                  onBackgroundImageError: (e, stackTrace) {
                                    print('Error loading profile image: $e');
                                    // Handle the error by showing a default image
                                  },
                                ),
                                if (_isEditing)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.orangeAccent,
                                      child: IconButton(
                                        icon: const Icon(Icons.camera_alt,
                                            color: Colors.white),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoTile('User ID',
                              userData['_id']?.toString() ?? '', Icons.badge,
                              editable: false),
                          _buildInfoTile(
                              'Name', userData['name'] ?? '', Icons.person,
                              controller: _nameController),
                          _buildInfoTile(
                              'Email', userData['email'] ?? '', Icons.email,
                              controller: _emailController,
                              editable: false), // Email should not be editable
                          _buildInfoTile('Contact No',
                              userData['contactNo'] ?? '', Icons.phone,
                              controller: _contactController),

                          // Subscription status
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subscription Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: userData['is_premium']
                                        ? Colors.amber.withOpacity(0.2)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      userData['is_premium']
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: userData['is_premium']
                                          ? Colors.amber
                                          : Colors.grey,
                                    ),
                                    title: Text(
                                      userData['is_premium']
                                          ? 'Premium User'
                                          : 'Free User',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: userData['is_premium']
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: userData['premium_until'] != null
                                        ? Text(
                                            'Premium until: ${userData['premium_until'].toString().split('T')[0]}')
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Subscription button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (ctx) => const SubscriptionPage(),
                                  ),
                                )
                                    .then((_) async {
                                  // Refresh user data when returning from subscription page
                                  await ref
                                      .read(userProvider.notifier)
                                      .checkAuthStatus();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                userData['is_premium']
                                    ? "Manage Subscription"
                                    : "Become a Premium User",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  _logout(context);
                                },
                                child: const Text("Logout")),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon,
      {bool editable = true, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(icon, color: Colors.orangeAccent),
              title: _isEditing && editable
                  ? TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter $label',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $label';
                        }
                        return null;
                      },
                    )
                  : Text(value, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    // Update userData with new values
    Map<String, dynamic> updateData = {
      'name': _nameController.text,
      'contactNo': _contactController.text,
      // Need to include email for server identification
      'email': userData['email'],
    };

    try {
      setState(() {
        _isLoading = true;
      });

      // 1. Update on server using API
      final response = await ApiService.updateProfile(updateData);

      if (response == null || !response.containsKey('message')) {
        throw Exception("Failed to update profile on server");
      }

      // 2. Update local state
      setState(() {
        userData['name'] = _nameController.text;
        userData['contactNo'] = _contactController.text;
      });

      // 3. Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userPhone', _contactController.text);

      // 4. Update provider state using class method
      // Call the static method correctly
      await UserNotifier.updateProfile(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
