import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/ads/ad_config.dart';
import 'core/services/ads_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/google_mobile_ads_service.dart';
import 'core/services/no_op_ads_service.dart';
import 'core/services/no_op_analytics_service.dart';
import 'core/services/no_op_audio_service.dart';
import 'core/services/shared_preferences_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesStorageService storageService =
      SharedPreferencesStorageService();
  await storageService.initialize();
  final AdsService adsService = kIsWeb
      ? NoOpAdsService()
      : GoogleMobileAdsService(adConfig: AdConfig.fromEnvironment());
  await adsService.initialize();
  final AudioService audioService = NoOpAudioService();
  await audioService.setSoundEnabled(storageService.getSoundEnabled());
  final AnalyticsService analyticsService = NoOpAnalyticsService();
  runApp(
    MergeGridApp(
      storageService: storageService,
      adsService: adsService,
      audioService: audioService,
      analyticsService: analyticsService,
    ),
  );
}
