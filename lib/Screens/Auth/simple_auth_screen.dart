import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/config/api_config.dart';
import 'package:mini_books/providers/books_collection_provider.dart';
import 'package:mini_books/providers/favorites_provider.dart';
import 'package:mini_books/services/premium_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../NavBar/nav_bar.dart';
import 'package:flutter/services.dart'; // For clipboard
import 'package:share_plus/share_plus.dart'; // For sharing referral code

class SimpleAuthScreen extends ConsumerStatefulWidget {
  const SimpleAuthScreen({super.key});

  @override
  ConsumerState<SimpleAuthScreen> createState() => _SimpleAuthScreenState();
}

class _SimpleAuthScreenState extends ConsumerState<SimpleAuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    // _checkIfLoggedIn();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  // // Check if user is already logged in
  // Future<void> _checkIfLoggedIn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  //   if (isLoggedIn) {
  //     // Navigate to home screen if already logged in
  //     if (mounted) {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => const FluidNavBarDemo()),
  //       );
  //     }
  //   }
  // }

  // Update _saveUserData in simple_auth_screen.dart to include referral code
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Log what we're receiving to help debug
      print('Saving user data: $userData');

      await prefs.setBool('isLoggedIn', true);

      // Handle potentially null or different data formats
      // Use null-safe code with better fallbacks
      await prefs.setString('userId', userData['id']?.toString() ?? '');
      await prefs.setString('userEmail', userData['email']?.toString() ?? '');
      await prefs.setString('userName', userData['name']?.toString() ?? '');
      await prefs.setString(
          'userPhone', userData['contactNo']?.toString() ?? '');
      await prefs.setString(
          'referralCode', userData['referral_code']?.toString() ?? '');
      await prefs.setInt('referralsCount', userData['referrals_count'] ?? 0);

      // Use null check before accessing Boolean values
      final isPremium = userData['is_premium'];
      await prefs.setBool('isPremium', isPremium is bool ? isPremium : false);

      if (userData['profile_image'] != null) {
        await prefs.setString(
            'profileImage', userData['profile_image'].toString());
      }

      // Sync subscription status with backend
      final userEmail = userData['email']?.toString();
      if (userEmail != null && userEmail.isNotEmpty) {
        await PremiumService.syncWithBackend(userEmail);
      }

      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
      // Re-throw to handle in the calling function
      rethrow;
    }
  }

  // Validate referral code
  Future<bool> _validateReferralCode(String code) async {
    if (code.isEmpty) {
      // Empty code is valid (optional field)
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/validate-referral-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      final data = jsonDecode(response.body);
      return data['valid'] ?? false;
    } catch (e) {
      print('Error validating referral code: $e');
      return false;
    }
  }

  // Submit form for login or register
  Future<void> _submit() async {
    try {
      // Validate form
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      final url = isLogin
          ? '${ApiConfig.baseUrl}/api/users/login'
          : '${ApiConfig.baseUrl}/api/users/register';

      // Prepare request body
      final Map<String, dynamic> requestBody = isLogin
          ? {
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }
          : {
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'contactNo': _phoneController.text.trim(),
              'referral_code': _referralCodeController.text.trim(),
            };

      print('Request URL: $url');
      print('Request body: $requestBody');

      // Make API call with better error handling
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout - Please check your internet connection');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Better response handling with proper error checking
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Safely parse JSON with error handling
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Failed to parse server response: $e');
        }

        // Check if the user data exists in the response
        if (responseData.containsKey('user')) {
          if (isLogin) {
            // Save user data from login response
            await _saveUserData(responseData['user']);
          } else {
            // For registration, we now need to handle two cases:
            // 1. If the response already contains login info (user + token)
            // 2. If we need to perform a separate login request

            // Save registration user data first (this might contain the referral_code)
            await _saveUserData(responseData['user']);

            // Then proceed with login for consistency
            final loginResponse = await http
                .post(
                  Uri.parse('${ApiConfig.baseUrl}/api/users/login'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode({
                    'email': _emailController.text.trim(),
                    'password': _passwordController.text,
                  }),
                )
                .timeout(const Duration(seconds: 30));

            print(
                'Login after registration - Status: ${loginResponse.statusCode}');
            print('Login after registration - Body: ${loginResponse.body}');

            if (loginResponse.statusCode == 200) {
              final loginData = jsonDecode(loginResponse.body);
              // Check for the user data in the correct location in the response
              if (loginData.containsKey('user')) {
                // Merge the login response with any data from registration (to preserve referral code)
                Map<String, dynamic> mergedUserData = {
                  ...responseData['user'],
                  ...loginData['user']
                };
                await _saveUserData(mergedUserData);
              } else if (loginData.containsKey('data') &&
                  loginData['data'] is Map) {
                // Alternative structure - some APIs return data.user
                Map<String, dynamic> mergedUserData = {
                  ...responseData['user'],
                  ...loginData['data']
                };
                await _saveUserData(mergedUserData);
              } else {
                throw Exception(
                    'Invalid login response format after registration');
              }
            } else {
              throw Exception(
                  'Registration successful but login failed. Please try logging in manually.');
            }
          }

          // Use a try-catch block for the operations after successful login
          try {
            // Refresh favorites and collections after login
            await ref.read(favoriteBooksProvider.notifier).refreshFavorites();
            await ref
                .read(bookCollectionsProvider.notifier)
                .refreshCollections();

            // Navigate to home screen
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const FluidNavBarDemo()),
              );
            }
          } catch (e) {
            print('Error after login: $e');
            // Don't throw here, we want to continue even if refresh fails
          }
        } else if (responseData.containsKey('data') &&
            responseData['data'] is Map) {
          // Alternative API structure - some APIs nest user data under 'data'
          if (isLogin) {
            await _saveUserData(responseData['data']);
          } else {
            // Similar handling for registration with alternative structure
            await _saveUserData(responseData['data']);

            final loginResponse = await http
                .post(
                  Uri.parse('${ApiConfig.baseUrl}/api/users/login'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode({
                    'email': _emailController.text.trim(),
                    'password': _passwordController.text,
                  }),
                )
                .timeout(const Duration(seconds: 30));

            if (loginResponse.statusCode == 200) {
              final loginData = jsonDecode(loginResponse.body);
              Map<String, dynamic> userData;
              if (loginData.containsKey('user')) {
                userData = loginData['user'];
              } else if (loginData.containsKey('data')) {
                userData = loginData['data'];
              } else {
                throw Exception(
                    'Invalid login response format after registration');
              }

              // Merge data to preserve referral code
              Map<String, dynamic> mergedUserData = {
                ...responseData['data'],
                ...userData
              };
              await _saveUserData(mergedUserData);
            }
          }

          // Continue with post-login operations
          try {
            await ref.read(favoriteBooksProvider.notifier).refreshFavorites();
            await ref
                .read(bookCollectionsProvider.notifier)
                .refreshCollections();

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const FluidNavBarDemo()),
              );
            }
          } catch (e) {
            print('Error after login: $e');
          }
        } else {
          throw Exception('Invalid response format: user data not found');
        }
      } else {
        // Handle HTTP error codes
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ??
              'Server returned status code ${response.statusCode}';
        } catch (e) {
          errorMessage = 'Server returned status code ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Show error dialog with more detailed information
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(isLogin ? 'Login Error' : 'Registration Error'),
            content: Text(error.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  print("Auth error is: $error");
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _switchAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Colors.orange;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.orange[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLogin
                                ? Icons.book_outlined
                                : Icons.app_registration,
                            size: 40,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          isLogin ? 'Welcome Back' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLogin
                              ? 'Sign in to continue'
                              : 'Sign up to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Fields
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          constraints: BoxConstraints(
                            maxHeight: isLogin ? 180 : 300,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Name field (only for signup)
                                if (!isLogin)
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon:
                                          const Icon(Icons.person_outline),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (!isLogin &&
                                          (value == null || value.isEmpty)) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                if (!isLogin) const SizedBox(height: 16),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || !value.contains('@')) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone field (only for signup)
                                if (!isLogin)
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon:
                                          const Icon(Icons.phone_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (!isLogin &&
                                          (value == null ||
                                              value.length < 10)) {
                                        return 'Invalid phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                if (!isLogin) const SizedBox(height: 16),

                                // Referral Code field (optional)
                                if (!isLogin)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _referralCodeController,
                                        decoration: InputDecoration(
                                          labelText: 'Referral Code (Optional)',
                                          prefixIcon:
                                              const Icon(Icons.card_giftcard),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        validator: (value) {
                                          // Referral code is optional, so no validation needed here
                                          return null;
                                        },
                                      ),
                                      if (_referralCodeController
                                              .text.isNotEmpty &&
                                          _referralCodeController.text.length <
                                              4)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'Referral code must be at least 4 characters',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                if (!isLogin) const SizedBox(height: 16),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isLogin ? 'LOGIN' : 'SIGN UP',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Switch between login and signup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogin
                                  ? "Don't have an account? "
                                  : 'Already have an account? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: _switchAuthMode,
                              child: Text(
                                isLogin ? 'Sign Up' : 'Login',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
