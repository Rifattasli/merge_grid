import '../../domain/entities/game_session_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/services/spawn_service.dart';
import '../../domain/usecases/start_game_use_case.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl()
    : _startGameUseCase = const StartGameUseCase(SpawnService());

  final StartGameUseCase _startGameUseCase;

  @override
  GameSessionEntity createNewSession() {
    return _startGameUseCase();
  }
}
