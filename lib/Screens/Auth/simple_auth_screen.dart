import 'dart:ui'; // For BackdropFilter
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
    // Dismiss keyboard immediately for better visual appeal
    FocusScope.of(context).unfocus();

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
        final responseData = jsonDecode(response.body);

        if (isLogin) {
          // Handle login response
          if (responseData.containsKey('user')) {
            await _saveUserData(responseData['user']);

            // Navigate after successful login
            if (mounted) {
              // Make sure we stay on the loading screen for at least 1 second for visual feedback
              // even if the response comes back quickly
              final authStartTime = DateTime.now();
              final minimumLoadingDuration = const Duration(seconds: 1);

              // Load user data and prepare for navigation
              await ref.read(favoriteBooksProvider.notifier).refreshFavorites();
              await ref
                  .read(bookCollectionsProvider.notifier)
                  .refreshCollections();

              // Check if we need to wait a bit more for the animation to be visible
              final elapsedTime = DateTime.now().difference(authStartTime);
              if (elapsedTime < minimumLoadingDuration) {
                await Future.delayed(minimumLoadingDuration - elapsedTime);
              }

              // Now navigate to home screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const FluidNavBarDemo()),
              );
            }
          } else {
            throw Exception(
                'Invalid login response format: user data not found');
          }
        } else {
          // Registration flow
          // Store the referral code from the registration response
          String? referralCode;
          if (responseData.containsKey('referral_code')) {
            // The API returns referral_code directly in the response
            referralCode = responseData['referral_code'] as String?;
          }

          // Proceed with auto-login
          final loginResponse = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/api/users/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          );

          print('Login response status: ${loginResponse.statusCode}');
          print('Login response body: ${loginResponse.body}');

          if (loginResponse.statusCode == 200) {
            final loginData = jsonDecode(loginResponse.body);

            if (loginData.containsKey('user')) {
              Map<String, dynamic> userData = {...loginData['user']};

              // If we got a referral code from registration and it's not set in login response,
              // add it to the userData
              if (referralCode != null && referralCode.isNotEmpty) {
                userData['referral_code'] = referralCode;
              }

              await _saveUserData(userData);

              // Navigate to home screen
              if (mounted) {
                // Make sure we stay on the loading screen for at least 1 second for visual feedback
                // even if the response comes back quickly
                final authStartTime = DateTime.now();
                final minimumLoadingDuration = const Duration(seconds: 1);

                // Load user data and prepare for navigation
                await ref
                    .read(favoriteBooksProvider.notifier)
                    .refreshFavorites();
                await ref
                    .read(bookCollectionsProvider.notifier)
                    .refreshCollections();

                // Check if we need to wait a bit more for the animation to be visible
                final elapsedTime = DateTime.now().difference(authStartTime);
                if (elapsedTime < minimumLoadingDuration) {
                  await Future.delayed(minimumLoadingDuration - elapsedTime);
                }

                // Now navigate to home screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const FluidNavBarDemo()),
                );
              }
            } else {
              throw Exception(
                  'Auto-login after registration failed: user data not found');
            }
          } else {
            throw Exception('Registration successful but auto-login failed');
          }
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
      // Show error dialog
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
    return Scaffold(
      // Keep your existing scaffold properties (background, appBar, etc.)

      body: Stack(
        children: [
          // Your existing body with the authentication form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
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
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLogin
                              ? Icons.book_outlined
                              : Icons.app_registration,
                          size: 40,
                          color: Colors.orange,
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
                                  prefixIcon: const Icon(Icons.email_outlined),
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
                                    hintText: '+91XXXXXXXXXX',
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    // Regex pattern for country code + 10 digits
                                    // Allows formats like: +911234567890 or +1234567890
                                    final RegExp phoneRegex =
                                        RegExp(r'^\+\d{1,3}\d{10}$');
                                    if (!phoneRegex.hasMatch(value)) {
                                      return 'Please enter a valid phone number with country code (+XX) followed by 10 digits';
                                    }
                                    return null;
                                  },
                                  // Add input formatting to restrict input length and format
                                  inputFormatters: [
                                    // Allow only + and digits
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\+\d]')),
                                    // Limit total length to 13 characters (+ and up to 12 digits)
                                    LengthLimitingTextInputFormatter(13),
                                  ],
                                ),
                              if (!isLogin) const SizedBox(height: 16),

                              // Referral Code field (optional)
                              if (!isLogin)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        _referralCodeController.text.length < 4)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Referral code must be at least 4 characters',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
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
                          onPressed: _isLoading
                              ? null
                              : () {
                                  // Dismiss keyboard when button is pressed
                                  FocusScope.of(context).unfocus();
                                  _submit();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
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
                                color: Colors.orange,
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

          // Full-screen overlay with the GIF animation when loading
          if (_isLoading)
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                // More transparent gradient for a glassy look
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orange.withOpacity(0.65), // More transparent
                      Colors.deepOrange.withOpacity(0.60), // More transparent
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 8,
                      sigmaY: 8), // Increased blur for glassier effect
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // GIF loading animation with larger size
                        Container(
                          padding: const EdgeInsets.all(
                              20), // Increased padding for larger container
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                                30), // Increased border radius
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Image.asset(
                            'assets/animations/loading4.gif',
                            height: 240, // Increased from 180 to 240
                            width: 240, // Increased from 180 to 240
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Status text with glass-like styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.25), // More transparent
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    0.1), // More transparent shadow
                                blurRadius: 15,
                                spreadRadius: 0,
                              ),
                            ],
                            // Add a subtle border for more glass-like appearance
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            isLogin
                                ? 'Logging in...'
                                : 'Creating your account...',
                            style: TextStyle(
                              color: Colors
                                  .white, // White text for better contrast
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
