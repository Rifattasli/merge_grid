import 'package:merge_grid/core/services/ads_service.dart';

class FakeAdsService implements AdsService {
  FakeAdsService({
    this.rewardedAdReady = false,
    this.rewardedResult = false,
    this.interstitialShownResult = false,
  });

  bool rewardedAdReady;
  bool rewardedResult;
  bool interstitialShownResult;
  int completedRuns = 0;
  int rewardedShowAttempts = 0;
  int interstitialShowAttempts = 0;

  @override
  bool get isRewardedContinueAdReady => rewardedAdReady;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> maybeShowInterstitialForCompletedRun() async {
    interstitialShowAttempts++;
    return interstitialShownResult;
  }

  @override
  Future<bool> showInterstitialOnDemand() async {
    interstitialShowAttempts++;
    return interstitialShownResult;
  }

  @override
  void preloadInterstitialAd() {}

  @override
  void preloadRewardedContinueAd() {}

  @override
  void registerCompletedRun() {
    completedRuns++;
  }

  @override
  Future<bool> showRewardedContinueAd() async {
    rewardedShowAttempts++;
    return rewardedResult;
  }

  @override
  void dispose() {}
}
