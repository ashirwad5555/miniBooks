import 'package:flutter/material.dart';
import 'package:mini_books/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../NavBar/nav_bar.dart';

class SimpleAuthScreen extends StatefulWidget {
  const SimpleAuthScreen({super.key});

  @override
  State<SimpleAuthScreen> createState() => _SimpleAuthScreenState();
}

class _SimpleAuthScreenState extends State<SimpleAuthScreen>
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
    _checkIfLoggedIn();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Check if user is already logged in
  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Navigate to home screen if already logged in
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FluidNavBarDemo()),
        );
      }
    }
  }

  // Save user data from API response
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    // Make sure to store the ID as a string
    await prefs.setString('userId', userData['id']?.toString() ?? '');
    await prefs.setString('userEmail', userData['email'] ?? '');
    await prefs.setString('userName', userData['name'] ?? '');
    await prefs.setString('userPhone', userData['contactNo'] ?? '');
    await prefs.setBool('isPremium', userData['is_premium'] ?? false);

    if (userData['profile_image'] != null) {
      await prefs.setString('profileImage', userData['profile_image']);
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
            };

      // Make API call
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Parse response
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isLogin) {
          // Save user data from login response
          await _saveUserData(responseData['user']);
        } else {
          // For registration, we need to log in
          final loginResponse = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/api/users/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          );

          if (loginResponse.statusCode == 200) {
            final loginData = jsonDecode(loginResponse.body);
            await _saveUserData(loginData['user']);
          } else {
            throw Exception(
                'Registration successful but login failed. Please try logging in.');
          }
        }

        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const FluidNavBarDemo()),
          );
        }
      } else {
        // Handle error
        throw Exception(responseData['error'] ?? 'Authentication failed');
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
                  print(
                      ".........................................auth error is $error");
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
    final primaryColor = Colors.orange;
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
                                style: TextStyle(
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
