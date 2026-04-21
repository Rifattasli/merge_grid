import '../entities/game_session_entity.dart';

abstract interface class GameRepository {
  GameSessionEntity createNewSession();
}
