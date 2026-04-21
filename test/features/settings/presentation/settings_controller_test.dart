import 'package:flutter_test/flutter_test.dart';

import 'package:merge_grid/features/settings/presentation/controllers/settings_controller.dart';
import '../../../helpers/fake_audio_service.dart';
import '../../../helpers/in_memory_storage_service.dart';

void main() {
  group('SettingsController persistence', () {
    test('loads and saves sound preference', () async {
      final InMemoryStorageService storageService = InMemoryStorageService(
        soundEnabled: false,
      );

      final SettingsController controller = SettingsController(
        storageService: storageService,
        audioService: FakeAudioService(),
      );

      expect(controller.isSoundEnabled, isFalse);

      await controller.setSoundEnabled(true);

      expect(controller.isSoundEnabled, isTrue);
      expect(storageService.getSoundEnabled(), isTrue);
    });
  });
}
