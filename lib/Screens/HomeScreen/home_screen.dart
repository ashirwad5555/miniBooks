import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_books/Notifications/notifications.dart';
import 'package:mini_books/Theme/mytheme.dart';
import '../Collection/favorites.dart';
import 'category_books_widget.dart';
import 'horizontal_scroll_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd _bannerAd;
  bool isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: "ca-app-pub-6953864367287284/7427671718",
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(onAdLoaded: (_) {
        setState(() {
          isBannerAdReady = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        isBannerAdReady = false;
        ad.dispose();
      }),
    );
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    // Access current theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: AppTheme.getGradientDecoration(),
        ),
        title: Text(
          "Mini-Books",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_outlined, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const FavoriteBooksScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => NotificationsPage()));
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad banner with improved styling
            if (isBannerAdReady)
              Container(
                width: double.infinity,
                height: _bannerAd.size.height.toDouble(),
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: AdWidget(ad: _bannerAd),
              ),               
          
            // Horizontal scroll widget with books
            const HorizontalScrollWidget(),

            // Section title for book categories
            

            // Category books widget
            const CategoryBooksWidget(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
