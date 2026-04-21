abstract interface class StorageService {
  Future<void> initialize();

  int getBestScore();
  Future<void> setBestScore(int value);

  int getTotalCoins();
  Future<void> setTotalCoins(int value);

  bool getSoundEnabled();
  Future<void> setSoundEnabled(bool value);
}
