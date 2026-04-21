import '../enums/game_status.dart';
import 'block_entity.dart';
import 'board_entity.dart';

class GameSessionEntity {
  const GameSessionEntity({
    required this.board,
    required this.nextBlock,
    required this.status,
    required this.score,
    required this.coins,
    required this.turnCount,
    required this.updatedAt,
  });

  factory GameSessionEntity.initial({
    required BoardEntity board,
    required BlockEntity nextBlock,
    required DateTime startedAt,
  }) {
    return GameSessionEntity(
      board: board,
      nextBlock: nextBlock,
      status: GameStatus.inProgress,
      score: 0,
      coins: 0,
      turnCount: 0,
      updatedAt: startedAt,
    );
  }

  final BoardEntity board;
  final BlockEntity nextBlock;
  final GameStatus status;
  final int score;
  final int coins;
  final int turnCount;
  final DateTime updatedAt;

  bool get isGameOver => status == GameStatus.gameOver;

  GameSessionEntity copyWith({
    BoardEntity? board,
    BlockEntity? nextBlock,
    GameStatus? status,
    int? score,
    int? coins,
    int? turnCount,
    DateTime? updatedAt,
  }) {
    return GameSessionEntity(
      board: board ?? this.board,
      nextBlock: nextBlock ?? this.nextBlock,
      status: status ?? this.status,
      score: score ?? this.score,
      coins: coins ?? this.coins,
      turnCount: turnCount ?? this.turnCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
