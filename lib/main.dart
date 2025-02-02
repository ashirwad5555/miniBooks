import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_books/Screens/HomeScreen/home_screen.dart';
import 'package:mini_books/Screens/temp/test1.dart';

import 'NavBar/nav_bar.dart';
import 'Screens/GoogleAdds/googleAddsHome.dart';
import 'Screens/SplashScreen/splash_screen.dart';
import 'Screens/Subscription/GooglePay/GPayByCardHome.dart';
import 'Screens/Subscription/GooglePay/paySampleApp.dart';
import 'Screens/temp/test2.dart';
import 'Theme/mytheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Light theme
      themeMode: ThemeMode.system, // Automatically switches based on system settings
      home: FluidNavBarDemo(),
    );
  }
}

