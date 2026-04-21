import '../entities/block_entity.dart';
import '../entities/board_entity.dart';
import '../enums/block_level.dart';

class MergeStepResult {
  const MergeStepResult({
    required this.fromLevel,
    required this.toLevel,
    required this.consumedBlocks,
  });

  final BlockLevel fromLevel;
  final BlockLevel toLevel;
  final int consumedBlocks;
}

class MergeResolution {
  const MergeResolution({required this.board, required this.steps});

  final BoardEntity board;
  final List<MergeStepResult> steps;

  bool get didMerge => steps.isNotEmpty;
}

class MergeRuleService {
  const MergeRuleService();

  MergeResolution resolve({
    required BoardEntity board,
    required int row,
    required int column,
  }) {
    BoardEntity currentBoard = board;
    final List<MergeStepResult> steps = <MergeStepResult>[];

    while (true) {
      final BlockEntity? originBlock = currentBoard.cellAt(row, column).block;
      if (originBlock == null) {
        break;
      }

      final List<(int, int)> matchingGroup = _collectMatchingGroup(
        board: currentBoard,
        row: row,
        column: column,
        level: originBlock.level,
      );

      if (matchingGroup.length < 3) {
        break;
      }

      final BlockLevel? upgradedLevel = originBlock.level.nextLevel;
      if (upgradedLevel == null) {
        break;
      }

      for (final (int targetRow, int targetColumn) in matchingGroup) {
        if (targetRow == row && targetColumn == column) {
          continue;
        }

        currentBoard = currentBoard.clearBlock(
          row: targetRow,
          column: targetColumn,
        );
      }

      currentBoard = currentBoard.setBlock(
        row: row,
        column: column,
        block: originBlock.upgrade(),
      );

      steps.add(
        MergeStepResult(
          fromLevel: originBlock.level,
          toLevel: upgradedLevel,
          consumedBlocks: matchingGroup.length,
        ),
      );
    }

    return MergeResolution(board: currentBoard, steps: steps);
  }

  List<(int, int)> _collectMatchingGroup({
    required BoardEntity board,
    required int row,
    required int column,
    required BlockLevel level,
  }) {
    final List<(int, int)> queue = <(int, int)>[(row, column)];
    final Set<(int, int)> visited = <(int, int)>{};

    while (queue.isNotEmpty) {
      final (int currentRow, int currentColumn) = queue.removeLast();
      if (!visited.add((currentRow, currentColumn))) {
        continue;
      }

      for (final neighbor in board.neighborsOf(currentRow, currentColumn)) {
        final BlockEntity? neighborBlock = neighbor.block;
        if (neighborBlock == null || neighborBlock.level != level) {
          continue;
        }

        final (int, int) neighborPosition = (neighbor.row, neighbor.column);
        if (!visited.contains(neighborPosition)) {
          queue.add(neighborPosition);
        }
      }
    }

    return visited.toList();
  }
}
