import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_config.dart';
import 'ads_service.dart';

class GoogleMobileAdsService implements AdsService {
  GoogleMobileAdsService({required AdConfig adConfig}) : _adConfig = adConfig;

  final AdConfig _adConfig;

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isRewardedLoading = false;
  bool _isInterstitialLoading = false;
  bool _isShowingFullscreenAd = false;
  int _completedRunsSinceInterstitial = 0;

  @override
  bool get isRewardedContinueAdReady => _rewardedAd != null;

  @override
  Future<void> initialize() async {
    if (!_supportsMobileAds) {
      return;
    }

    await MobileAds.instance.initialize();
    preloadRewardedContinueAd();
    preloadInterstitialAd();
  }

  @override
  void preloadRewardedContinueAd() {
    if (!_supportsMobileAds || _isRewardedLoading || _rewardedAd != null) {
      return;
    }

    if (_adConfig.rewardedAdUnitId.isEmpty) {
      debugPrint('Rewarded ad unit ID missing. Skipping rewarded preload.');
      return;
    }

    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: _adConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isRewardedLoading = false;
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  @override
  void preloadInterstitialAd() {
    if (!_supportsMobileAds ||
        _isInterstitialLoading ||
        _interstitialAd != null) {
      return;
    }

    if (_adConfig.interstitialAdUnitId.isEmpty) {
      debugPrint('Interstitial ad unit ID missing. Skipping preload.');
      return;
    }

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: _adConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _isInterstitialLoading = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  @override
  void registerCompletedRun() {
    _completedRunsSinceInterstitial++;
    preloadInterstitialAd();
  }

  @override
  Future<bool> showRewardedContinueAd() async {
    if (!_supportsMobileAds || _isShowingFullscreenAd) {
      return false;
    }

    final RewardedAd? ad = _rewardedAd;
    if (ad == null) {
      preloadRewardedContinueAd();
      return false;
    }

    _rewardedAd = null;
    final Completer<bool> completer = Completer<bool>();
    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdShowedFullScreenContent: (_) {
        _isShowingFullscreenAd = true;
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _isShowingFullscreenAd = false;
        unawaited(ad.dispose());
        preloadRewardedContinueAd();
        if (!completer.isCompleted) {
          completer.complete(rewarded);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        _isShowingFullscreenAd = false;
        unawaited(ad.dispose());
        preloadRewardedContinueAd();
        debugPrint('Rewarded ad failed to show: $error');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        rewarded = true;
      },
    );

    return completer.future;
  }

  @override
  Future<bool> maybeShowInterstitialForCompletedRun() async {
    if (!_supportsMobileAds ||
        _isShowingFullscreenAd ||
        _completedRunsSinceInterstitial < _adConfig.interstitialInterval) {
      return false;
    }

    final InterstitialAd? ad = _interstitialAd;
    if (ad == null) {
      preloadInterstitialAd();
      return false;
    }

    _interstitialAd = null;
    _completedRunsSinceInterstitial = 0;
    final Completer<bool> completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (_) {
        _isShowingFullscreenAd = true;
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _isShowingFullscreenAd = false;
        unawaited(ad.dispose());
        preloadInterstitialAd();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _isShowingFullscreenAd = false;
        unawaited(ad.dispose());
        preloadInterstitialAd();
        debugPrint('Interstitial ad failed to show: $error');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.show();
    return completer.future;
  }

  @override
  Future<bool> showInterstitialOnDemand() async {
    if (!_supportsMobileAds || _isShowingFullscreenAd) {
      return false;
    }

    final InterstitialAd? ad = _interstitialAd;
    if (ad == null) {
      preloadInterstitialAd();
      return false;
    }

    _interstitialAd = null;
    final Completer<bool> completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (_) {
        _isShowingFullscreenAd = true;
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _isShowingFullscreenAd = false;
        unawaited(ad.dispose());
        preloadInterstitialAd();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _isShowingFullscreenAd = false;
        unawaited(ad.dispose());
        preloadInterstitialAd();
        debugPrint('Interstitial ad failed to show: $error');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.show();
    return completer.future;
  }

  @override
  void dispose() {
    unawaited(_rewardedAd?.dispose());
    unawaited(_interstitialAd?.dispose());
    _rewardedAd = null;
    _interstitialAd = null;
  }

  bool get _supportsMobileAds {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
