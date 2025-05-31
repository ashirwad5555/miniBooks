import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:mini_books/Screens/Collection/bookShelf.dart';
import 'package:mini_books/Screens/HomeScreen/home_screen.dart';
import '../Screens/Explore/explore_page.dart';
import '../Screens/Profile/user_profile.dart';
import '../Theme/mytheme.dart'; // Import the theme

class FluidNavBarDemo extends StatefulWidget {
  const FluidNavBarDemo({super.key});

  @override
  State createState() {
    return _FluidNavBarDemoState();
  }
}

class _FluidNavBarDemoState extends State {
  Widget? _child;

  @override
  void initState() {
    _child = const HomeScreen();
    super.initState();
  }

  @override
  Widget build(context) {
    // Build a simple container that switches content based of off the selected navigation item
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF75B7E1),
        extendBody: true,
        body: _child,
        bottomNavigationBar: FluidNavBar(
          animationFactor: 1,
          icons: [
            FluidNavBarIcon(
                icon: Icons.search,
                backgroundColor: const Color(0xFFEC4134),
                extras: {"label": "search"}),
            FluidNavBarIcon(
                icon: Icons.home_filled,
                backgroundColor: const Color.fromRGBO(245, 148, 92, 1),
                extras: {"label": "home"}),
            FluidNavBarIcon(
                icon: const IconData(0xe3dd, fontFamily: 'MaterialIcons'),
                backgroundColor: const Color(0xFF34A950),
                extras: {"label": "subscription"}),
            FluidNavBarIcon(
                icon: Icons.person,
                backgroundColor: const Color(0xFFFCBA02),
                extras: {"label": "profile"}),
          ],
          onChange: _handleNavigationChange,
          style: FluidNavBarStyle(
              iconUnselectedForegroundColor: Colors.white,
              barBackgroundColor: AppTheme.gradientStart
                  .withOpacity(0.3)), // Changed background color here
          scaleFactor: 1.5,
          defaultIndex: 1,
          itemBuilder: (icon, item) => Semantics(
            label: icon.extras!["label"],
            child: item,
          ),
        ),
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = const ExplorePage();
          break;
        case 1:
          _child = const HomeScreen();
          break;
        case 2:
          _child = const BookShelfScreen();
          break;
        case 3:
          _child = const UserProfile();
          break;
      }
      _child = AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        duration: const Duration(milliseconds: 950),
        child: _child,
      );
    });
  }
}
