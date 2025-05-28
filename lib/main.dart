import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_books/Screens/Auth/simple_auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NavBar/nav_bar.dart';
import 'Theme/mytheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final prefs = snapshot.data!;
          final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
          
          return MaterialApp(
            title: 'Mini Books',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: isLoggedIn ? const FluidNavBarDemo(): const SimpleAuthScreen(),
          );
        }
        
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
