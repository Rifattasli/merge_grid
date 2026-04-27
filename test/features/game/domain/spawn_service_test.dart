import 'package:flutter_test/flutter_test.dart';

import 'package:merge_grid/features/game/domain/enums/block_level.dart';
import 'package:merge_grid/features/game/domain/services/spawn_service.dart';

void main() {
  group('SpawnService unlock rules', () {
    const SpawnService spawnService = SpawnService();

    test('starts with only level 1 unlocked', () {
      expect(
        spawnService.getUnlockedSpawnLevels(highestBlockLevel: 1),
        <BlockLevel>[BlockLevel.one],
      );
      expect(spawnService.getMaxUnlockedSpawnLevel(highestBlockLevel: 1), 1);
    });

    test('unlocks spawn level 2 at highest block level 4', () {
      expect(
        spawnService.getUnlockedSpawnLevels(highestBlockLevel: 4),
        <BlockLevel>[BlockLevel.one, BlockLevel.two],
      );
      expect(spawnService.getMaxUnlockedSpawnLevel(highestBlockLevel: 4), 2);
    });

    test('unlocks spawn level 3 at highest block level 6', () {
      expect(
        spawnService.getUnlockedSpawnLevels(highestBlockLevel: 6),
        <BlockLevel>[BlockLevel.one, BlockLevel.two, BlockLevel.three],
      );
      expect(spawnService.getMaxUnlockedSpawnLevel(highestBlockLevel: 6), 3);
    });

    test('unlocks spawn level 4 at highest block level 8', () {
      expect(
        spawnService.getUnlockedSpawnLevels(highestBlockLevel: 8),
        <BlockLevel>[
          BlockLevel.one,
          BlockLevel.two,
          BlockLevel.three,
          BlockLevel.four,
        ],
      );
      expect(spawnService.getMaxUnlockedSpawnLevel(highestBlockLevel: 8), 4);
    });
  });

  group('SpawnService weighted selection', () {
    const SpawnService spawnService = SpawnService();

    test('uses 90/10 weighting for highest block level 4 to 5', () {
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 4, randomPercent: 0),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 5, randomPercent: 89),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 4, randomPercent: 90),
        BlockLevel.two,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 5, randomPercent: 99),
        BlockLevel.two,
      );
    });

    test('uses 75/20/5 weighting for highest block level 6 to 7', () {
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 6, randomPercent: 0),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 7, randomPercent: 74),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 6, randomPercent: 75),
        BlockLevel.two,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 7, randomPercent: 94),
        BlockLevel.two,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 6, randomPercent: 95),
        BlockLevel.three,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 7, randomPercent: 99),
        BlockLevel.three,
      );
    });

    test('uses 65/25/8/2 weighting for highest block level 8 to 9', () {
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 8, randomPercent: 0),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 9, randomPercent: 64),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 8, randomPercent: 65),
        BlockLevel.two,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 9, randomPercent: 89),
        BlockLevel.two,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 8, randomPercent: 90),
        BlockLevel.three,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 9, randomPercent: 97),
        BlockLevel.three,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 8, randomPercent: 98),
        BlockLevel.four,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 9, randomPercent: 99),
        BlockLevel.four,
      );
    });

    test('uses 55/30/12/3 weighting for highest block level 10+', () {
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 10, randomPercent: 0),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 12, randomPercent: 54),
        BlockLevel.one,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 10, randomPercent: 55),
        BlockLevel.two,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 12, randomPercent: 84),
        BlockLevel.two,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 10, randomPercent: 85),
        BlockLevel.three,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 12, randomPercent: 96),
        BlockLevel.three,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 10, randomPercent: 97),
        BlockLevel.four,
      );
      expect(
        spawnService.selectSpawnLevel(highestBlockLevel: 12, randomPercent: 99),
        BlockLevel.four,
      );
    });

    test('createNextBlock can eventually spawn level 3 and level 4', () {
      final levelThreeBlock = spawnService.createNextBlock(
        turnCount: 20,
        highestBlockLevel: 6,
        randomPercent: 95,
      );
      final levelFourBlock = spawnService.createNextBlock(
        turnCount: 30,
        highestBlockLevel: 8,
        randomPercent: 99,
      );

      expect(levelThreeBlock.level, BlockLevel.three);
      expect(levelFourBlock.level, BlockLevel.four);
    });

    test('unlocking level 4 still allows low levels to spawn', () {
      final levelOneBlock = spawnService.createNextBlock(
        turnCount: 30,
        highestBlockLevel: 8,
        randomPercent: 10,
      );
      final levelTwoBlock = spawnService.createNextBlock(
        turnCount: 30,
        highestBlockLevel: 8,
        randomPercent: 70,
      );
      final levelThreeBlock = spawnService.createNextBlock(
        turnCount: 30,
        highestBlockLevel: 8,
        randomPercent: 92,
      );

      expect(levelOneBlock.level, BlockLevel.one);
      expect(levelTwoBlock.level, BlockLevel.two);
      expect(levelThreeBlock.level, BlockLevel.three);
    });

    test('level 4 remains rare even after it unlocks', () {
      final levelFourEarly = spawnService.createNextBlock(
        turnCount: 30,
        highestBlockLevel: 8,
        randomPercent: 98,
      );
      final levelFourLate = spawnService.createNextBlock(
        turnCount: 40,
        highestBlockLevel: 10,
        randomPercent: 97,
      );
      final stillMostlyLevelOne = spawnService.createNextBlock(
        turnCount: 40,
        highestBlockLevel: 10,
        randomPercent: 20,
      );

      expect(levelFourEarly.level, BlockLevel.four);
      expect(levelFourLate.level, BlockLevel.four);
      expect(stillMostlyLevelOne.level, BlockLevel.one);
    });
  });
}
