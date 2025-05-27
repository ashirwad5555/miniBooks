import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Googleaddshome extends StatefulWidget {
  const Googleaddshome({super.key});

  @override
  State<Googleaddshome> createState() => _GoogleaddshomeState();
}

class _GoogleaddshomeState extends State<Googleaddshome> {
  late BannerAd _bannerAd;
  bool isBannerAdReady = false;

  late InterstitialAd _interstitialAd;
  bool isInterstitialAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
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

    InterstitialAd.load(
      adUnitId: "ca-app-pub-6953864367287284/3281377294",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
        setState(() {
          _interstitialAd = ad;
          isInterstitialAdReady = true;
        }
        );
      },
          onAdFailedToLoad: (error) {
        isInterstitialAdReady = false;

      }),
    );

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd.dispose();
    if(isBannerAdReady)
      {
        _interstitialAd.dispose();
      }
  }

  void _showInterstitialAd()
  {
    if(isInterstitialAdReady)
      {
        _interstitialAd.show();
        _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad)
              {
                ad.dispose();
                setState(() {
                  isInterstitialAdReady = false;
                });
              },
              onAdFailedToShowFullScreenContent: (ad, error)
            {
              ad.dispose();
              setState(() {
                isInterstitialAdReady = false;
              });
            }
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 200,),
          ElevatedButton(onPressed: (){
            _showInterstitialAd();
          }, child: const Text("show interstitial Add")),

        ],
      ),
      bottomNavigationBar: isBannerAdReady ? SizedBox(
        height: _bannerAd.size.height.toDouble(),
        width: _bannerAd.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd),
      ): null
    );
  }
}
