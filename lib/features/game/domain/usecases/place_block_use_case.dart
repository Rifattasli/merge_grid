import '../entities/game_session_entity.dart';
import '../enums/game_status.dart';
import '../services/idle_income_service.dart';
import '../services/lose_condition_service.dart';
import '../services/score_service.dart';
import '../services/spawn_service.dart';
import 'resolve_merge_use_case.dart';

class PlaceBlockUseCase {
  const PlaceBlockUseCase({
    required SpawnService spawnService,
    required ResolveMergeUseCase resolveMergeUseCase,
    required ScoreService scoreService,
    required LoseConditionService loseConditionService,
    required IdleIncomeService idleIncomeService,
  }) : _spawnService = spawnService,
       _resolveMergeUseCase = resolveMergeUseCase,
       _scoreService = scoreService,
       _loseConditionService = loseConditionService,
       _idleIncomeService = idleIncomeService;

  final SpawnService _spawnService;
  final ResolveMergeUseCase _resolveMergeUseCase;
  final ScoreService _scoreService;
  final LoseConditionService _loseConditionService;
  final IdleIncomeService _idleIncomeService;

  GameSessionEntity call({
    required GameSessionEntity session,
    required int row,
    required int column,
    DateTime? playedAt,
  }) {
    if (session.isGameOver) {
      throw StateError('Cannot place a block after the game is over.');
    }

    final DateTime moveTime = playedAt ?? session.updatedAt;
    final int idleCoins = _idleIncomeService.calculateCoins(
      board: session.board,
      from: session.updatedAt,
      to: moveTime,
    );

    final placedBoard = session.board.placeBlock(
      row: row,
      column: column,
      block: session.nextBlock,
    );

    final resolution = _resolveMergeUseCase(
      board: placedBoard,
      row: row,
      column: column,
    );

    final int nextTurnCount = session.turnCount + 1;
    final int updatedScore =
        session.score + _scoreService.calculateMergeScore(resolution);
    final bool hasLost = _loseConditionService.isGameOver(resolution.board);

    return session.copyWith(
      board: resolution.board,
      nextBlock: hasLost
          ? session.nextBlock
          : _spawnService.createNextBlock(
              turnCount: nextTurnCount,
              highestBlockLevel: resolution.board.highestBlockLevel,
            ),
      status: hasLost ? GameStatus.gameOver : GameStatus.inProgress,
      score: updatedScore,
      coins: session.coins + idleCoins,
      turnCount: nextTurnCount,
      updatedAt: moveTime,
    );
  }
}
