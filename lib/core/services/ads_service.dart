abstract interface class AdsService {
  Future<void> initialize();

  bool get isRewardedContinueAdReady;

  void preloadRewardedContinueAd();
  void preloadInterstitialAd();

  void registerCompletedRun();

  Future<bool> showRewardedContinueAd();
  Future<bool> showInterstitialOnDemand();
  Future<bool> maybeShowInterstitialForCompletedRun();

  void dispose();
}
