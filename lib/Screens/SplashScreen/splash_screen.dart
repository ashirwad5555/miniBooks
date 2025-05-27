import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_books/Screens/Auth/simple_auth_screen.dart';
import '../Auth/auth_screen.dart';
import '../../NavBar/nav_bar.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final Widget Function()? onInitComplete;

  const SplashScreen({super.key, this.onInitComplete});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _navigationAttempted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    // Check authentication state
    _checkAuth();

    // Add a safety timeout to ensure we don't get stuck
    Timer(const Duration(seconds: 5), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _checkAuth() async {
    try {
      // Initialize auth state with a timeout
      await ref
          .read(userProvider.notifier)
          .checkAuthStatus()
          .timeout(const Duration(seconds: 3), onTimeout: () {
        // If timeout occurs, just continue to login screen
        print('Auth check timed out');
        return;
      });

      // Short delay for animation
      await Future.delayed(const Duration(seconds: 2));

      _navigateToNextScreen();
    } catch (e) {
      print('Error during auth check: $e');
      // If there's an error, we'll still navigate but after a delay
      await Future.delayed(const Duration(seconds: 2));
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Only navigate if we haven't already and the widget is still mounted
    if (!_navigationAttempted && mounted) {
      _navigationAttempted = true;

      if (widget.onInitComplete != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.onInitComplete!()),
        );
      } else {
        // Fallback to AuthScreen if callback is not provided
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SimpleAuthScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[300]!, Colors.deepOrange],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Mini-Books',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 40),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
