enum AudioEffect { tap, merge, coin, gameOver, continueRun }

abstract interface class AudioService {
  Future<void> setSoundEnabled(bool isEnabled);
  Future<void> playEffect(AudioEffect effect);
}
