import 'package:merge_grid/core/services/audio_service.dart';

class FakeAudioService implements AudioService {
  bool isSoundEnabled = true;
  final List<AudioEffect> playedEffects = <AudioEffect>[];

  @override
  Future<void> setSoundEnabled(bool isEnabled) async {
    isSoundEnabled = isEnabled;
  }

  @override
  Future<void> playEffect(AudioEffect effect) async {
    if (!isSoundEnabled) {
      return;
    }

    playedEffects.add(effect);
  }
}
