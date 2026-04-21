import '../entities/board_entity.dart';
import '../entities/game_session_entity.dart';
import '../services/spawn_service.dart';

class StartGameUseCase {
  const StartGameUseCase(this._spawnService);

  final SpawnService _spawnService;

  GameSessionEntity call({DateTime? startedAt}) {
    final DateTime sessionStartTime = startedAt ?? DateTime.now();

    return GameSessionEntity.initial(
      board: BoardEntity.empty(),
      nextBlock: _spawnService.createNextBlock(
        turnCount: 0,
        occupiedCells: 0,
        highestBlockLevel: 1,
      ),
      startedAt: sessionStartTime,
    );
  }
}
