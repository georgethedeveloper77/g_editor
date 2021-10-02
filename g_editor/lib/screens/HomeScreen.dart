import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/components/AppLogoWidget.dart';
import 'package:photo_editor_pro/components/HomeItemListWidget.dart';
import 'package:photo_editor_pro/components/LastEditedPicturesWidget.dart';
import 'package:photo_editor_pro/main.dart';
import 'package:photo_editor_pro/utils/Constants.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (!disableAdMob) myBanner = buildBannerAd()..load();

    setStatusBarColor(Colors.white70);
  }

  BannerAd buildBannerAd() {
    return
      BannerAd(
      size: AdSize.banner,
      request: AdRequest(),
      adUnitId: kReleaseMode ? mAdMobBannerId : BannerAd.testAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          log('${ad.runtimeType} loaded.');
          myBanner = ad as BannerAd;
          myBanner!.load();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          log('${ad.runtimeType} failed to load: $error.');
          ad.dispose();
          bannerReady = true;
        },
        onAdOpened: (Ad ad) {
          log('${ad.runtimeType} onAdOpened.');
        },
        onAdClosed: (Ad ad) {
          log('${ad.runtimeType} closed.');
          ad.dispose();
        },
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    myBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AdSize.banner.height.toDouble()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLogoWidget(),
                  HomeItemListWidget(),
                  LastEditedPicturesWidget(),
                ],
              ),
            ),

            /*Banner Home ad*/
           /* if (myBanner != null)
              Positioned(
                child: Container(child: myBanner != null ? AdWidget(ad: myBanner!) : SizedBox(), color: Color(0xFFEEF6FD)),
                bottom: 0,
                height: AdSize.banner.height.toDouble(),
                width: context.width(),
              ),*/

          ],
        ),
      ),
    );
  }
}
