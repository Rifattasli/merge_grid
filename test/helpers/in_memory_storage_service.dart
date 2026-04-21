import 'package:merge_grid/core/services/storage_service.dart';

class InMemoryStorageService implements StorageService {
  int _bestScore;
  int _totalCoins;
  bool _soundEnabled;

  InMemoryStorageService({
    int bestScore = 0,
    int totalCoins = 0,
    bool soundEnabled = true,
  }) : _bestScore = bestScore,
       _totalCoins = totalCoins,
       _soundEnabled = soundEnabled;

  @override
  Future<void> initialize() async {}

  @override
  int getBestScore() => _bestScore;

  @override
  Future<void> setBestScore(int value) async {
    _bestScore = value;
  }

  @override
  int getTotalCoins() => _totalCoins;

  @override
  Future<void> setTotalCoins(int value) async {
    _totalCoins = value;
  }

  @override
  bool getSoundEnabled() => _soundEnabled;

  @override
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
  }
}
