import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:merge_grid/core/services/ads_service.dart';
import 'package:merge_grid/core/services/analytics_service.dart';
import 'package:merge_grid/core/services/audio_service.dart';
import 'package:merge_grid/features/game/domain/entities/block_entity.dart';
import 'package:merge_grid/features/game/domain/entities/board_entity.dart';
import 'package:merge_grid/features/game/domain/entities/game_session_entity.dart';
import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/enums/game_status.dart';
import 'package:merge_grid/features/game/presentation/controllers/game_controller.dart';
import 'package:merge_grid/features/game/presentation/pages/game_page.dart';
import '../../../helpers/fake_ads_service.dart';
import '../../../helpers/fake_analytics_service.dart';
import '../../../helpers/fake_audio_service.dart';
import '../../../helpers/in_memory_storage_service.dart';

void main() {
  testWidgets('pause overlay opens and resumes from the HUD', (
    WidgetTester tester,
  ) async {
    final FakeAdsService adsService = FakeAdsService();
    final FakeAudioService audioService = FakeAudioService();
    final FakeAnalyticsService analyticsService = FakeAnalyticsService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AdsService>.value(value: adsService),
          Provider<AudioService>.value(value: audioService),
          Provider<AnalyticsService>.value(value: analyticsService),
          ChangeNotifierProvider<GameController>(
            create: (_) => GameController(
              storageService: InMemoryStorageService(),
              audioService: audioService,
              analyticsService: analyticsService,
            ),
          ),
        ],
        child: const MaterialApp(home: GamePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Score'), findsOneWidget);
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pump();

    expect(find.text('Paused'), findsNothing);
  });

  testWidgets('game over overlay shows continue placeholder', (
    WidgetTester tester,
  ) async {
    final FakeAudioService audioService = FakeAudioService();
    final FakeAnalyticsService analyticsService = FakeAnalyticsService();
    final GameController controller = GameController(
      storageService: InMemoryStorageService(),
      audioService: audioService,
      analyticsService: analyticsService,
    );
    final FakeAdsService adsService = FakeAdsService();
    BoardEntity board = BoardEntity.empty();
    int counter = 0;

    for (int row = 0; row < board.size; row++) {
      for (int column = 0; column < board.size; column++) {
        counter++;
        board = board.setBlock(
          row: row,
          column: column,
          block: BlockEntity(id: 'b$counter', level: BlockLevel.one),
        );
      }
    }

    controller.restoreSession(
      GameSessionEntity(
        board: board,
        nextBlock: const BlockEntity(id: 'next', level: BlockLevel.one),
        status: GameStatus.gameOver,
        score: 120,
        coins: 8,
        turnCount: 25,
        updatedAt: DateTime(2026, 1, 1, 12),
      ),
      bestScore: 200,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AdsService>.value(value: adsService),
          Provider<AudioService>.value(value: audioService),
          Provider<AnalyticsService>.value(value: analyticsService),
          ChangeNotifierProvider<GameController>(create: (_) => controller),
        ],
        child: const MaterialApp(home: GamePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Game Over'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(
      find.text('Watch a rewarded ad to continue this run once.'),
      findsOneWidget,
    );
  });

  testWidgets('new game button requests an interstitial ad', (
    WidgetTester tester,
  ) async {
    final FakeAdsService adsService = FakeAdsService();
    final FakeAudioService audioService = FakeAudioService();
    final FakeAnalyticsService analyticsService = FakeAnalyticsService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AdsService>.value(value: adsService),
          Provider<AudioService>.value(value: audioService),
          Provider<AnalyticsService>.value(value: analyticsService),
          ChangeNotifierProvider<GameController>(
            create: (_) => GameController(
              storageService: InMemoryStorageService(),
              audioService: audioService,
              analyticsService: analyticsService,
            ),
          ),
        ],
        child: const MaterialApp(home: GamePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('New Game'));
    await tester.pump();

    expect(adsService.interstitialShowAttempts, 1);
  });
}
