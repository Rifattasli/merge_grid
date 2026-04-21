import 'ads_service.dart';

class NoOpAdsService implements AdsService {
  @override
  bool get isRewardedContinueAdReady => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> maybeShowInterstitialForCompletedRun() async => false;

  @override
  Future<bool> showInterstitialOnDemand() async => false;

  @override
  void preloadInterstitialAd() {}

  @override
  void preloadRewardedContinueAd() {}

  @override
  void registerCompletedRun() {}

  @override
  Future<bool> showRewardedContinueAd() async => false;

  @override
  void dispose() {}
}
