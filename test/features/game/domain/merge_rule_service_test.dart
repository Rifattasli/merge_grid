import 'package:flutter_test/flutter_test.dart';
import 'package:merge_grid/features/game/domain/entities/block_entity.dart';
import 'package:merge_grid/features/game/domain/entities/board_entity.dart';
import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/services/merge_rule_service.dart';

void main() {
  group('MergeRuleService', () {
    test('merges three matching orthogonal blocks into the next level', () {
      const mergeRuleService = MergeRuleService();

      final BoardEntity board = BoardEntity.empty()
          .setBlock(
            row: 2,
            column: 2,
            block: const BlockEntity(id: 'center', level: BlockLevel.one),
          )
          .setBlock(
            row: 2,
            column: 1,
            block: const BlockEntity(id: 'left', level: BlockLevel.one),
          )
          .setBlock(
            row: 2,
            column: 3,
            block: const BlockEntity(id: 'right', level: BlockLevel.one),
          );

      final MergeResolution result = mergeRuleService.resolve(
        board: board,
        row: 2,
        column: 2,
      );

      expect(result.didMerge, isTrue);
      expect(result.steps, hasLength(1));
      expect(result.board.cellAt(2, 2).block?.level, BlockLevel.two);
      expect(result.board.cellAt(2, 1).block, isNull);
      expect(result.board.cellAt(2, 3).block, isNull);
    });

    test('supports chained merges from the upgraded center block', () {
      const mergeRuleService = MergeRuleService();

      BoardEntity board = BoardEntity.empty()
          .setBlock(
            row: 2,
            column: 2,
            block: const BlockEntity(id: 'center', level: BlockLevel.one),
          )
          .setBlock(
            row: 2,
            column: 1,
            block: const BlockEntity(id: 'left', level: BlockLevel.one),
          )
          .setBlock(
            row: 2,
            column: 3,
            block: const BlockEntity(id: 'right', level: BlockLevel.one),
          )
          .setBlock(
            row: 1,
            column: 2,
            block: const BlockEntity(id: 'top', level: BlockLevel.two),
          )
          .setBlock(
            row: 3,
            column: 2,
            block: const BlockEntity(id: 'bottom', level: BlockLevel.two),
          );

      final MergeResolution result = mergeRuleService.resolve(
        board: board,
        row: 2,
        column: 2,
      );

      expect(result.steps, hasLength(2));
      expect(result.board.cellAt(2, 2).block?.level, BlockLevel.three);
      expect(result.board.cellAt(1, 2).block, isNull);
      expect(result.board.cellAt(3, 2).block, isNull);
    });
  });
}
