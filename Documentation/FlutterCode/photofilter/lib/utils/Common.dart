import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/main.dart';

import 'Constants.dart';

extension IntExt on int {
  Size get size => Size(this.toDouble(), this.toDouble());
}

String get getBannerAdId => kReleaseMode ? mAdMobBannerId : BannerAd.testAdUnitId;

String get getInterstitialId => kReleaseMode ? mAdMobInterstitialId : InterstitialAd.testAdUnitId;

String get getNativeAdvancedId => kReleaseMode ? mAdMobNativeAdvancedId : NativeAd.testAdUnitId;

String get getRewardedId => kReleaseMode ? mAdMobRewardedId : RewardedAd.testAdUnitId;

void createInterstitialAd() {
  InterstitialAd.load(
    adUnitId: kReleaseMode ? mAdMobInterstitialId : InterstitialAd.testAdUnitId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        log('${ad.runtimeType} loaded.');
        interstitialReady = true;
        myInterstitial = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        log('InterstitialAd failed to load: $error.');
        myInterstitial = null;
      },
    ),
  );
}

void showInterstitialAd(BuildContext context, {bool aIsFinish = true}) {
  if (myInterstitial == null) {
    log('attempt to show interstitial before loaded.');
    if (aIsFinish) {
      finish(context);
    }
    return;
  }
  myInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      log('$ad onAdDismissedFullScreenContent.');
      createInterstitialAd();
      myInterstitial!.dispose();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      log('$ad onAdFailedToShowFullScreenContent: $error');
      createInterstitialAd();
      myInterstitial!.dispose();
    },
  );
  myInterstitial!.show();
}
