import 'audio_service.dart';

class NoOpAudioService implements AudioService {
  bool _isSoundEnabled = true;

  @override
  Future<void> setSoundEnabled(bool isEnabled) async {
    _isSoundEnabled = isEnabled;
  }

  @override
  Future<void> playEffect(AudioEffect effect) async {
    if (!_isSoundEnabled) {
      return;
    }
  }
}
