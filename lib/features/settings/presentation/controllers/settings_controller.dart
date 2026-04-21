import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    required StorageService storageService,
    required AudioService audioService,
  }) : _storageService = storageService,
       _audioService = audioService,
       _isSoundEnabled = storageService.getSoundEnabled() {
    unawaited(_audioService.setSoundEnabled(_isSoundEnabled));
  }

  final StorageService _storageService;
  final AudioService _audioService;
  bool _isSoundEnabled;

  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> setSoundEnabled(bool isEnabled) async {
    if (_isSoundEnabled == isEnabled) {
      return;
    }

    _isSoundEnabled = isEnabled;
    notifyListeners();
    await _storageService.setSoundEnabled(isEnabled);
    await _audioService.setSoundEnabled(isEnabled);
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
    await _storageService.setSoundEnabled(_isSoundEnabled);
    await _audioService.setSoundEnabled(_isSoundEnabled);
  }
}
