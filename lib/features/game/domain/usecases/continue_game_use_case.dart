import '../entities/cell_entity.dart';
import '../entities/game_session_entity.dart';
import '../enums/game_status.dart';

class ContinueGameUseCase {
  const ContinueGameUseCase();

  GameSessionEntity call({
    required GameSessionEntity session,
    DateTime? continuedAt,
  }) {
    if (session.status != GameStatus.gameOver) {
      return session;
    }

    final List<CellEntity> occupiedCells =
        session.board.cells
            .where((CellEntity cell) => cell.block != null)
            .toList()
          ..sort((CellEntity left, CellEntity right) {
            final int byLevel = left.block!.level.value.compareTo(
              right.block!.level.value,
            );
            if (byLevel != 0) {
              return byLevel;
            }

            final int byRow = left.row.compareTo(right.row);
            if (byRow != 0) {
              return byRow;
            }

            return left.column.compareTo(right.column);
          });

    if (occupiedCells.isEmpty) {
      return session.copyWith(
        status: GameStatus.inProgress,
        updatedAt: continuedAt ?? DateTime.now(),
      );
    }

    final CellEntity cellToClear = occupiedCells.first;

    return session.copyWith(
      board: session.board.clearBlock(
        row: cellToClear.row,
        column: cellToClear.column,
      ),
      status: GameStatus.inProgress,
      updatedAt: continuedAt ?? DateTime.now(),
    );
  }
}
