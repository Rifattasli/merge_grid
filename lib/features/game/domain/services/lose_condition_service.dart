import '../entities/board_entity.dart';

class LoseConditionService {
  const LoseConditionService();

  bool isGameOver(BoardEntity board) {
    return !board.hasEmptyCell;
  }
}
