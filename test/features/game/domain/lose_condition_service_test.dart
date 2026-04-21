import 'package:flutter_test/flutter_test.dart';
import 'package:merge_grid/features/game/domain/entities/block_entity.dart';
import 'package:merge_grid/features/game/domain/entities/board_entity.dart';
import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/services/lose_condition_service.dart';

void main() {
  group('LoseConditionService', () {
    test('returns false when the board still has empty cells', () {
      const loseConditionService = LoseConditionService();

      final BoardEntity board = BoardEntity.empty().setBlock(
        row: 0,
        column: 0,
        block: const BlockEntity(id: 'a', level: BlockLevel.one),
      );

      expect(loseConditionService.isGameOver(board), isFalse);
    });

    test('returns true when the board is full', () {
      const loseConditionService = LoseConditionService();
      BoardEntity board = BoardEntity.empty();
      int counter = 0;

      for (int row = 0; row < board.size; row++) {
        for (int column = 0; column < board.size; column++) {
          counter++;
          board = board.setBlock(
            row: row,
            column: column,
            block: BlockEntity(id: 'b$counter', level: BlockLevel.one),
          );
        }
      }

      expect(loseConditionService.isGameOver(board), isTrue);
    });
  });
}
