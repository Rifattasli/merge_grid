import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../domain/services/idle_income_service.dart';
import '../../domain/services/lose_condition_service.dart';
import '../../domain/services/merge_rule_service.dart';
import '../../domain/services/score_service.dart';
import '../../domain/services/spawn_service.dart';
import '../../domain/usecases/continue_game_use_case.dart';
import '../../domain/usecases/place_block_use_case.dart';
import '../../domain/usecases/resolve_merge_use_case.dart';
import '../../domain/usecases/start_game_use_case.dart';
import '../models/game_feedback.dart';

class GameController extends ChangeNotifier {
  GameController({
    required StorageService storageService,
    required AudioService audioService,
    required AnalyticsService analyticsService,
  }) : _storageService = storageService,
       _audioService = audioService,
       _analyticsService = analyticsService,
       _startGameUseCase = const StartGameUseCase(SpawnService()),
       _idleIncomeService = const IdleIncomeService(),
       _placeBlockUseCase = PlaceBlockUseCase(
         spawnService: const SpawnService(),
         resolveMergeUseCase: const ResolveMergeUseCase(MergeRuleService()),
         scoreService: const ScoreService(),
         loseConditionService: const LoseConditionService(),
         idleIncomeService: const IdleIncomeService(),
       ),
       _continueGameUseCase = const ContinueGameUseCase(),
       _session = StartGameUseCase(const SpawnService())(),
       _bestScore = storageService.getBestScore(),
       _totalCoins = storageService.getTotalCoins() {
    _highestBlockReachedThisRun = _session.board.highestBlockLevel;
    _logGameStart();
  }

  final StorageService _storageService;
  final AudioService _audioService;
  final AnalyticsService _analyticsService;
  final StartGameUseCase _startGameUseCase;
  final IdleIncomeService _idleIncomeService;
  final PlaceBlockUseCase _placeBlockUseCase;
  final ContinueGameUseCase _continueGameUseCase;
  GameSessionEntity _session;
  int _bestScore;
  int _totalCoins;
  bool _hasUsedContinueThisRun = false;
  int _feedbackSequence = 0;
  GameFeedback? _latestFeedback;
  int _highestBlockReachedThisRun = 0;

  GameSessionEntity get session => _session;
  int get bestScore => _bestScore;
  int get totalCoins => _totalCoins;
  bool get canContinueAfterGameOver =>
      _session.isGameOver && !_hasUsedContinueThisRun;
  GameFeedback? get latestFeedback => _latestFeedback;
  bool get hasIdleCoinFlow => _session.board.totalBlockLevels > 0;
  int get displayedCoins => _totalCoins;

  void startNewGame() {
    _commitPendingIdleCoins();
    _session = _startGameUseCase();
    _hasUsedContinueThisRun = false;
    _latestFeedback = null;
    _highestBlockReachedThisRun = _session.board.highestBlockLevel;
    unawaited(_audioService.playEffect(AudioEffect.tap));
    _logGameStart();
    notifyListeners();
  }

  bool placeBlockAt({required int row, required int column}) {
    try {
      final GameSessionEntity previousSession = _session;
      final int previousSessionCoins = _session.coins;
      _session = _placeBlockUseCase(
        session: _session,
        row: row,
        column: column,
        playedAt: DateTime.now(),
      );
      final int earnedCoins = _session.coins - previousSessionCoins;
      if (earnedCoins > 0) {
        _totalCoins += earnedCoins;
        unawaited(_storageService.setTotalCoins(_totalCoins));
      }
      if (_session.score > _bestScore) {
        _bestScore = _session.score;
        unawaited(_storageService.setBestScore(_bestScore));
      }
      final int highestBlockLevel = _session.board.highestBlockLevel;
      int bonusCoins = 0;
      if (highestBlockLevel > _highestBlockReachedThisRun) {
        _highestBlockReachedThisRun = highestBlockLevel;
        bonusCoins = highestBlockLevel * 2;
        _totalCoins += bonusCoins;
        unawaited(_storageService.setTotalCoins(_totalCoins));
        unawaited(
          _analyticsService.logEvent(
            'highest_block_reached',
            parameters: <String, Object?>{
              'level': highestBlockLevel,
              'turn_count': _session.turnCount,
              'score': _session.score,
            },
          ),
        );
      }
      final int scoreGained = _session.score - previousSession.score;
      final int highlightLevel =
          _session.board.cellAt(row, column).block?.level.value ??
          previousSession.nextBlock.level.value;
      _latestFeedback = GameFeedback(
        sequence: ++_feedbackSequence,
        row: row,
        column: column,
        scoreGained: scoreGained,
        coinsGained: earnedCoins + bonusCoins,
        highlightLevel: highlightLevel,
        mergeCount: scoreGained > 0 ? 1 : 0,
        didTriggerGameOver: _session.isGameOver && !previousSession.isGameOver,
      );
      unawaited(_audioService.playEffect(AudioEffect.tap));
      if (scoreGained > 0) {
        unawaited(_audioService.playEffect(AudioEffect.merge));
      }
      if (earnedCoins > 0) {
        unawaited(_audioService.playEffect(AudioEffect.coin));
      }
      if (_session.isGameOver && !previousSession.isGameOver) {
        unawaited(_audioService.playEffect(AudioEffect.gameOver));
        unawaited(
          _analyticsService.logEvent(
            'game_end',
            parameters: <String, Object?>{
              'score': _session.score,
              'turn_count': _session.turnCount,
              'highest_block': _highestBlockReachedThisRun,
              'used_continue': _hasUsedContinueThisRun,
            },
          ),
        );
      }
      notifyListeners();
      return true;
    } on StateError {
      return false;
    }
  }

  void restoreSession(GameSessionEntity session, {int? bestScore}) {
    _session = session;
    _bestScore =
        bestScore ??
        (_session.score > _bestScore ? _session.score : _bestScore);
    notifyListeners();
  }

  bool continueAfterGameOver() {
    if (!canContinueAfterGameOver) {
      return false;
    }

    final GameSessionEntity previousSession = _session;
    _session = _continueGameUseCase(
      session: _session,
      continuedAt: DateTime.now(),
    );
    _hasUsedContinueThisRun = true;
    final firstOpenCell = _session.board.cells.firstWhere(
      (cell) => cell.block == null,
      orElse: () => _session.board.cells.first,
    );
    _latestFeedback = GameFeedback(
      sequence: ++_feedbackSequence,
      row: firstOpenCell.row,
      column: firstOpenCell.column,
      scoreGained: 0,
      coinsGained: 0,
      highlightLevel: previousSession.nextBlock.level.value,
      mergeCount: 0,
      didTriggerGameOver: false,
    );
    unawaited(_audioService.playEffect(AudioEffect.continueRun));
    unawaited(
      _analyticsService.logEvent(
        'rewarded_continue_used',
        parameters: <String, Object?>{
          'score': previousSession.score,
          'turn_count': previousSession.turnCount,
        },
      ),
    );
    notifyListeners();
    return true;
  }

  void _commitPendingIdleCoins() {
    final int pendingCoins = _idleIncomeService.calculateCoins(
      board: _session.board,
      from: _session.updatedAt,
      to: DateTime.now(),
    );
    if (pendingCoins <= 0) {
      return;
    }

    _totalCoins += pendingCoins;
    unawaited(_storageService.setTotalCoins(_totalCoins));
  }

  void _logGameStart() {
    unawaited(
      _analyticsService.logEvent(
        'game_start',
        parameters: <String, Object?>{
          'best_score': _bestScore,
          'total_coins': _totalCoins,
        },
      ),
    );
  }

  @override
  void dispose() {
    _commitPendingIdleCoins();
    super.dispose();
  }
}
