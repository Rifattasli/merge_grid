import '../entities/game_session_entity.dart';
import '../enums/game_status.dart';
import '../services/idle_income_service.dart';

class EndGameUseCase {
  const EndGameUseCase(this._idleIncomeService);

  final IdleIncomeService _idleIncomeService;

  GameSessionEntity call({
    required GameSessionEntity session,
    DateTime? endedAt,
  }) {
    final DateTime endTime = endedAt ?? session.updatedAt;
    final int idleCoins = _idleIncomeService.calculateCoins(
      board: session.board,
      from: session.updatedAt,
      to: endTime,
    );

    return session.copyWith(
      status: GameStatus.gameOver,
      coins: session.coins + idleCoins,
      updatedAt: endTime,
    );
  }
}
