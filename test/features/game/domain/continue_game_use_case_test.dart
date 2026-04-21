import 'package:flutter_test/flutter_test.dart';

import 'package:merge_grid/features/game/domain/entities/block_entity.dart';
import 'package:merge_grid/features/game/domain/entities/board_entity.dart';
import 'package:merge_grid/features/game/domain/entities/game_session_entity.dart';
import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/enums/game_status.dart';
import 'package:merge_grid/features/game/domain/usecases/continue_game_use_case.dart';

void main() {
  group('ContinueGameUseCase', () {
    test('clears one lowest-level cell and resumes the run', () {
      const ContinueGameUseCase useCase = ContinueGameUseCase();
      final BoardEntity board = BoardEntity.empty()
          .setBlock(
            row: 0,
            column: 0,
            block: const BlockEntity(id: 'a', level: BlockLevel.two),
          )
          .setBlock(
            row: 0,
            column: 1,
            block: const BlockEntity(id: 'b', level: BlockLevel.one),
          );

      final GameSessionEntity session = GameSessionEntity(
        board: board,
        nextBlock: const BlockEntity(id: 'next', level: BlockLevel.one),
        status: GameStatus.gameOver,
        score: 100,
        coins: 0,
        turnCount: 12,
        updatedAt: DateTime(2026, 1, 1),
      );

      final GameSessionEntity updated = useCase(
        session: session,
        continuedAt: DateTime(2026, 1, 1, 0, 5),
      );

      expect(updated.status, GameStatus.inProgress);
      expect(updated.board.cellAt(0, 1).block, isNull);
      expect(updated.board.cellAt(0, 0).block?.level, BlockLevel.two);
    });
  });
}
