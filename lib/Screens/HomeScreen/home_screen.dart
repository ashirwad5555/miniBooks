import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_books/Notifications/notifications.dart';
import 'package:mini_books/Screens/Collection/saved_books.dart';
import '../Collection/favorites.dart';
import '../temp/temp3.dart';
import 'books_list_module.dart';
import 'category_books_widget.dart';
import 'category_selector.dart';
import 'horizontal_scroll_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late BannerAd _bannerAd;
  bool isBannerAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: "ca-app-pub-6953864367287284/7427671718",
      request: AdRequest(),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Mini-Books", style: theme.textTheme.headlineLarge,),
        // backgroundColor: Color.fromRGBO(64, 64, 176, 0.68),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.book_outlined),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => FavoriteBooksScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NotificationsPage()));
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            isBannerAdReady ? SizedBox(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ): SizedBox(height: 0,),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: TextField(
            //     decoration: InputDecoration(
            //       hintText: 'Search',
            //       prefixIcon: Icon(Icons.search),
            //       suffixIcon: Icon(Icons.mic),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(30),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 16),
            HorizontalScrollWidget(),
            SizedBox(height: 16),
            CategoryBooksWidget(),
            SizedBox(height: 16),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Text(
            //     "You might like this",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // CategorySelector(),
            // BookListModule(),
            // SizedBox(height: 16),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Text(
            //     "You might like this",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // CategorySelector(),
            // BookListModule(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
