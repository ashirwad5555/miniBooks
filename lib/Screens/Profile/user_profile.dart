import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'dart:convert';
import '../../Theme/mytheme.dart';

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
          final prefs = await SharedPreferences.getInstance();
          final userEmail = prefs.getString('userEmail') ?? '';
          final profile = await ApiService.getUserProfile(userEmail);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    }
  }

  void _initControllers() {
    _nameController.text = userData['name'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _contactController.text = userData['contactNo'] ?? '';
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 500,
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });

      try {
        setState(() {
          _isLoading = true;
        });

        String base64Image = await imageToBase64(pickedImage.path);
        final result =
            await ApiService.uploadProfileImage(userData['email'], base64Image);

        if (result != null && result.containsKey('profile_image')) {
          final String imageUrl = result['profile_image'];
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

          // Update the global state in user provider - THIS IS THE KEY ADDITION
          if (ref.read(userProvider)['isAuthenticated']) {
            Map<String, dynamic> updatedUserData = {...ref.read(userProvider)['userData']  ?? {},
             'profile_image': fullImageUrl, };
             // Update the user state using notifier
            ref.read(userProvider.notifier).updateUser(updatedUserData);

          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Profile image updated successfully')),
            );
          }
        } else {
          throw Exception("Invalid response from server");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> imageToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    await prefs.remove('book_collections');
    await prefs.remove('favoriteBooks');

    ref.read(favoriteBooksProvider.notifier).refreshFavorites();
    ref.read(bookCollectionsProvider.notifier).refreshCollections();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SimpleAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userState = ref.watch(userProvider);
    final isAuthenticated = userState['isAuthenticated'];

    if (!isAuthenticated && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Navigate to login if needed
      });
    }

    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'My Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    _isEditing ? Icons.save_outlined : Icons.edit,
                    color: Colors.black,
                  ),
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
              ),
            ],
            flexibleSpace: Container(
              decoration: AppTheme.getGradientDecoration(),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Profile header with gradient background
                      Container(
                        decoration: AppTheme.getGradientDecoration(),
                        padding: const EdgeInsets.only(top: 90, bottom: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundColor: Colors.white,
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
                                        print(
                                            'Error loading profile image: $e');
                                      },
                                    ),
                                  ),
                                  if (_isEditing)
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              AppTheme.gradientStart,
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                userData['name'] ?? 'User',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.5),
                                      offset: const Offset(0, 1),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                userData['email'] ?? 'email@example.com',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Profile info form
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info section
                              Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Personal Information',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: AppTheme.gradientStart,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    _buildInfoTile(
                                      'User ID',
                                      userData['_id']?.toString() ?? '',
                                      Icons.badge,
                                      theme,
                                      colorScheme,
                                      editable: false,
                                    ),
                                    _buildInfoTile(
                                      'Name',
                                      userData['name'] ?? '',
                                      Icons.person,
                                      theme,
                                      colorScheme,
                                      controller: _nameController,
                                    ),
                                    _buildInfoTile(
                                      'Email',
                                      userData['email'] ?? '',
                                      Icons.email,
                                      theme,
                                      colorScheme,
                                      controller: _emailController,
                                      editable: false,
                                    ),
                                    _buildInfoTile(
                                      'Contact No',
                                      userData['contactNo'] ?? '',
                                      Icons.phone,
                                      theme,
                                      colorScheme,
                                      controller: _contactController,
                                    ),
                                  ],
                                ),
                              ),

                              // Subscription info section
                              Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Subscription',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: AppTheme.gradientStart,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: userData['is_premium']
                                                      ? Colors.amber
                                                          .withOpacity(0.1)
                                                      : Colors.grey
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  userData['is_premium']
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: userData['is_premium']
                                                      ? Colors.amber
                                                      : Colors.grey,
                                                  size: 30,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userData['is_premium']
                                                          ? 'Premium User'
                                                          : 'Free User',
                                                      style: theme
                                                          .textTheme.titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: userData[
                                                                'is_premium']
                                                            ? Colors.amber[700]
                                                            : colorScheme
                                                                .onSurface,
                                                      ),
                                                    ),
                                                    if (userData[
                                                            'premium_until'] !=
                                                        null)
                                                      Text(
                                                        'Premium until: ${userData['premium_until'].toString().split('T')[0]}',
                                                        style: theme.textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                          color: colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .push(
                                                  MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        const SubscriptionPage(),
                                                  ),
                                                )
                                                    .then((_) async {
                                                  await ref
                                                      .read(
                                                          userProvider.notifier)
                                                      .checkAuthStatus();
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    userData['is_premium']
                                                        ? Colors.amber
                                                        : AppTheme
                                                            .gradientStart,
                                                foregroundColor:
                                                    userData['is_premium']
                                                        ? Colors.black
                                                        : Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                elevation: 4,
                                              ),
                                              child: Text(
                                                userData['is_premium']
                                                    ? "Manage Subscription"
                                                    : "Become a Premium User",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Logout button
                              Container(
                                margin: const EdgeInsets.only(bottom: 40.0),
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.logout),
                                  label: const Text("Logout"),
                                  onPressed: () => _logout(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade100,
                                    foregroundColor: Colors.red.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.gradientStart),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool editable = true,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.gradientStart.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isEditing && editable
                      ? TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Enter $label',
                            hintStyle: TextStyle(
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.gradientStart.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.gradientStart,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter $label';
                            }
                            return null;
                          },
                        )
                      : Text(
                          value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    Map<String, dynamic> updateData = {
      'name': _nameController.text,
      'contactNo': _contactController.text,
      'email': userData['email'],
    };

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await ApiService.updateProfile(updateData);

      if (response == null || !response.containsKey('message')) {
        throw Exception("Failed to update profile on server");
      }

      setState(() {
        userData['name'] = _nameController.text;
        userData['contactNo'] = _contactController.text;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userPhone', _contactController.text);

      await UserNotifier.updateProfile(updateData);

      // Update the global user state - REPLACE the static call with this
      if (ref.read(userProvider)['isAuthenticated']) {
        Map<String, dynamic> updatedUserData = {
          ...ref.read(userProvider)['userData'] ?? {},
          'name': _nameController.text,
          'contactNo': _contactController.text,
        };

        // Update the user state using notifier
        ref.read(userProvider.notifier).updateUser(updatedUserData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
