import 'package:flutter_test/flutter_test.dart';

import 'package:merge_grid/features/game/presentation/controllers/game_controller.dart';
import '../../../helpers/fake_analytics_service.dart';
import '../../../helpers/fake_audio_service.dart';
import '../../../helpers/in_memory_storage_service.dart';

void main() {
  group('GameController persistence', () {
    test('loads persisted best score and total coins on startup', () {
      final InMemoryStorageService storageService = InMemoryStorageService(
        bestScore: 180,
        totalCoins: 42,
      );

      final GameController controller = GameController(
        storageService: storageService,
        audioService: FakeAudioService(),
        analyticsService: FakeAnalyticsService(),
      );
      addTearDown(controller.dispose);

      expect(controller.bestScore, 180);
      expect(controller.totalCoins, 42);
    });

    test('logs game start analytics event', () async {
      final FakeAnalyticsService analyticsService = FakeAnalyticsService();
      final GameController controller = GameController(
        storageService: InMemoryStorageService(),
        audioService: FakeAudioService(),
        analyticsService: analyticsService,
      );
      addTearDown(controller.dispose);

      controller.startNewGame();
      await Future<void>.delayed(Duration.zero);

      expect(
        analyticsService.events.any((event) => event.name == 'game_start'),
        isTrue,
      );
    });
  });
}
