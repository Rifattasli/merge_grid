import 'package:flutter/foundation.dart';

class AdConfig {
  const AdConfig({
    required this.useTestAds,
    required this.androidRewardedAdUnitId,
    required this.iosRewardedAdUnitId,
    required this.androidInterstitialAdUnitId,
    required this.iosInterstitialAdUnitId,
    this.interstitialInterval = 3,
  });

  factory AdConfig.fromEnvironment() {
    return const AdConfig(
      useTestAds: bool.fromEnvironment('USE_TEST_ADS', defaultValue: true),
      androidRewardedAdUnitId: String.fromEnvironment(
        'ANDROID_REWARDED_AD_UNIT_ID',
      ),
      iosRewardedAdUnitId: String.fromEnvironment('IOS_REWARDED_AD_UNIT_ID'),
      androidInterstitialAdUnitId: String.fromEnvironment(
        'ANDROID_INTERSTITIAL_AD_UNIT_ID',
      ),
      iosInterstitialAdUnitId: String.fromEnvironment(
        'IOS_INTERSTITIAL_AD_UNIT_ID',
      ),
    );
  }

  final bool useTestAds;
  final String androidRewardedAdUnitId;
  final String iosRewardedAdUnitId;
  final String androidInterstitialAdUnitId;
  final String iosInterstitialAdUnitId;
  final int interstitialInterval;

  String get rewardedAdUnitId {
    if (useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917';
    }

    return defaultTargetPlatform == TargetPlatform.iOS
        ? iosRewardedAdUnitId
        : androidRewardedAdUnitId;
  }

  String get interstitialAdUnitId {
    if (useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }

    return defaultTargetPlatform == TargetPlatform.iOS
        ? iosInterstitialAdUnitId
        : androidInterstitialAdUnitId;
  }
}
