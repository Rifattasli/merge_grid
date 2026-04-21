import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

class SharedPreferencesStorageService implements StorageService {
  SharedPreferences? _preferences;

  static const String _bestScoreKey = 'best_score';
  static const String _totalCoinsKey = 'total_coins';
  static const String _soundEnabledKey = 'sound_enabled';

  @override
  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  int getBestScore() {
    return _prefs.getInt(_bestScoreKey) ?? 0;
  }

  @override
  Future<void> setBestScore(int value) async {
    await _prefs.setInt(_bestScoreKey, value);
  }

  @override
  int getTotalCoins() {
    return _prefs.getInt(_totalCoinsKey) ?? 0;
  }

  @override
  Future<void> setTotalCoins(int value) async {
    await _prefs.setInt(_totalCoinsKey, value);
  }

  @override
  bool getSoundEnabled() {
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }

  @override
  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(_soundEnabledKey, value);
  }

  SharedPreferences get _prefs {
    final SharedPreferences? preferences = _preferences;
    if (preferences == null) {
      throw StateError('StorageService must be initialized before use.');
    }

    return preferences;
  }
}
