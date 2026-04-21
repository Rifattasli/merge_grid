import 'package:flutter_test/flutter_test.dart';
import 'package:merge_grid/features/game/domain/entities/block_entity.dart';
import 'package:merge_grid/features/game/domain/entities/board_entity.dart';
import 'package:merge_grid/features/game/domain/entities/game_session_entity.dart';
import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/enums/game_status.dart';
import 'package:merge_grid/features/game/domain/services/idle_income_service.dart';
import 'package:merge_grid/features/game/domain/services/lose_condition_service.dart';
import 'package:merge_grid/features/game/domain/services/merge_rule_service.dart';
import 'package:merge_grid/features/game/domain/services/score_service.dart';
import 'package:merge_grid/features/game/domain/services/spawn_service.dart';
import 'package:merge_grid/features/game/domain/usecases/place_block_use_case.dart';
import 'package:merge_grid/features/game/domain/usecases/resolve_merge_use_case.dart';

void main() {
  group('PlaceBlockUseCase', () {
    test('places a block, resolves a merge, and updates the score', () {
      final PlaceBlockUseCase useCase = PlaceBlockUseCase(
        spawnService: const SpawnService(),
        resolveMergeUseCase: const ResolveMergeUseCase(MergeRuleService()),
        scoreService: const ScoreService(),
        loseConditionService: const LoseConditionService(),
        idleIncomeService: const IdleIncomeService(),
      );

      final GameSessionEntity session = GameSessionEntity(
        board: BoardEntity.empty()
            .setBlock(
              row: 2,
              column: 1,
              block: const BlockEntity(id: 'left', level: BlockLevel.one),
            )
            .setBlock(
              row: 2,
              column: 3,
              block: const BlockEntity(id: 'right', level: BlockLevel.one),
            ),
        nextBlock: const BlockEntity(id: 'next', level: BlockLevel.one),
        status: GameStatus.inProgress,
        score: 0,
        coins: 0,
        turnCount: 0,
        updatedAt: DateTime(2026, 1, 1, 12),
      );

      final GameSessionEntity updated = useCase(
        session: session,
        row: 2,
        column: 2,
        playedAt: DateTime(2026, 1, 1, 12, 1),
      );

      expect(updated.board.cellAt(2, 2).block?.level, BlockLevel.two);
      expect(updated.score, 60);
      expect(updated.turnCount, 1);
      expect(updated.status, GameStatus.inProgress);
    });
  });
}
