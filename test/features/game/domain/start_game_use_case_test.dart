import 'package:flutter_test/flutter_test.dart';
import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/enums/game_status.dart';
import 'package:merge_grid/features/game/domain/services/spawn_service.dart';
import 'package:merge_grid/features/game/domain/usecases/start_game_use_case.dart';

void main() {
  group('StartGameUseCase', () {
    test('creates a fresh game session with an empty 5x5 board', () {
      final StartGameUseCase useCase = StartGameUseCase(const SpawnService());
      final DateTime startedAt = DateTime(2026, 1, 1, 12);

      final session = useCase(startedAt: startedAt);

      expect(session.board.size, 5);
      expect(session.board.occupiedCellCount, 0);
      expect(session.score, 0);
      expect(session.coins, 0);
      expect(session.turnCount, 0);
      expect(session.status, GameStatus.inProgress);
      expect(session.nextBlock.level, BlockLevel.one);
      expect(session.updatedAt, startedAt);
    });
  });
}
