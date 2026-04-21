import 'package:flutter_test/flutter_test.dart';
import 'package:merge_grid/features/game/domain/entities/board_entity.dart';
import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/services/merge_rule_service.dart';
import 'package:merge_grid/features/game/domain/services/score_service.dart';

void main() {
  group('ScoreService', () {
    test('calculates score from each merge step', () {
      const scoreService = ScoreService();

      final MergeResolution resolution = MergeResolution(
        board: BoardEntity.empty(),
        steps: <MergeStepResult>[
          MergeStepResult(
            fromLevel: BlockLevel.one,
            toLevel: BlockLevel.two,
            consumedBlocks: 3,
          ),
          MergeStepResult(
            fromLevel: BlockLevel.two,
            toLevel: BlockLevel.three,
            consumedBlocks: 3,
          ),
        ],
      );

      expect(scoreService.calculateMergeScore(resolution), 150);
    });
  });
}
