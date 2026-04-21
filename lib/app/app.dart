import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/ads_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/storage_service.dart';
import '../features/game/presentation/controllers/game_controller.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import 'router.dart';

class MergeGridApp extends StatelessWidget {
  const MergeGridApp({
    super.key,
    required this.storageService,
    required this.adsService,
    required this.audioService,
    required this.analyticsService,
  });

  final StorageService storageService;
  final AdsService adsService;
  final AudioService audioService;
  final AnalyticsService analyticsService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<AdsService>.value(value: adsService),
        Provider<AudioService>.value(value: audioService),
        Provider<AnalyticsService>.value(value: analyticsService),
        ChangeNotifierProvider<GameController>(
          create: (_) => GameController(
            storageService: storageService,
            audioService: audioService,
            analyticsService: analyticsService,
          ),
        ),
        ChangeNotifierProvider<SettingsController>(
          create: (_) => SettingsController(
            storageService: storageService,
            audioService: audioService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Merge Grid',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F7A8C)),
          scaffoldBackgroundColor: const Color(0xFFF4F1EA),
          useMaterial3: true,
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.homeRoute,
      ),
    );
  }
}
