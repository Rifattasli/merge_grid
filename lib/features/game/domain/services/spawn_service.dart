import '../entities/block_entity.dart';
import '../enums/block_level.dart';

class SpawnService {
  const SpawnService();

  BlockEntity createNextBlock({
    required int turnCount,
    int occupiedCells = 0,
    int highestBlockLevel = 1,
  }) {
    final bool canIntroduceLevelTwo =
        turnCount >= 10 && occupiedCells >= 8 && highestBlockLevel >= 2;
    final bool shouldSpawnLevelTwo = canIntroduceLevelTwo && turnCount % 9 == 0;

    final BlockLevel level = shouldSpawnLevelTwo
        ? BlockLevel.two
        : BlockLevel.one;

    return BlockEntity(id: 'block_${turnCount + 1}', level: level);
  }
}
