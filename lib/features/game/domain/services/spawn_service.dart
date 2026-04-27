import 'dart:math';

import '../entities/block_entity.dart';
import '../enums/block_level.dart';

class SpawnService {
  const SpawnService();

  static final Random _random = Random();

  BlockEntity createNextBlock({
    required int turnCount,
    int highestBlockLevel = 1,
    int? randomPercent,
  }) {
    final BlockLevel level = selectSpawnLevel(
      highestBlockLevel: highestBlockLevel,
      randomPercent: randomPercent ?? _random.nextInt(100),
    );

    return BlockEntity(id: 'block_${turnCount + 1}', level: level);
  }

  int getMaxUnlockedSpawnLevel({required int highestBlockLevel}) {
    if (highestBlockLevel >= 8) {
      return 4;
    }
    if (highestBlockLevel >= 6) {
      return 3;
    }
    if (highestBlockLevel >= 4) {
      return 2;
    }

    return 1;
  }

  List<BlockLevel> getUnlockedSpawnLevels({required int highestBlockLevel}) {
    final int maxUnlockedSpawnLevel = getMaxUnlockedSpawnLevel(
      highestBlockLevel: highestBlockLevel,
    );

    return BlockLevel.values
        .where((BlockLevel level) => level.value <= maxUnlockedSpawnLevel)
        .toList(growable: false);
  }

  BlockLevel selectSpawnLevel({
    required int highestBlockLevel,
    required int randomPercent,
  }) {
    assert(randomPercent >= 0 && randomPercent < 100);

    final List<({BlockLevel level, int weight})> weightedPool =
        getWeightedSpawnPool(highestBlockLevel: highestBlockLevel);

    int cumulativeWeight = 0;
    for (final entry in weightedPool) {
      cumulativeWeight += entry.weight;
      if (randomPercent < cumulativeWeight) {
        return entry.level;
      }
    }

    return weightedPool.last.level;
  }

  List<({BlockLevel level, int weight})> getWeightedSpawnPool({
    required int highestBlockLevel,
  }) {
    if (highestBlockLevel < 3) {
      return <({BlockLevel level, int weight})>[
        (level: BlockLevel.one, weight: 100),
      ];
    }
    if (highestBlockLevel < 5) {
      return <({BlockLevel level, int weight})>[
        (level: BlockLevel.one, weight: 90),
        (level: BlockLevel.two, weight: 10),
      ];
    }
    if (highestBlockLevel < 7) {
      return <({BlockLevel level, int weight})>[
        (level: BlockLevel.one, weight: 75),
        (level: BlockLevel.two, weight: 20),
        (level: BlockLevel.three, weight: 5),
      ];
    }
    if (highestBlockLevel < 9) {
      return <({BlockLevel level, int weight})>[
        (level: BlockLevel.one, weight: 65),
        (level: BlockLevel.two, weight: 25),
        (level: BlockLevel.three, weight: 8),
        (level: BlockLevel.four, weight: 2),
      ];
    }

    return <({BlockLevel level, int weight})>[
      (level: BlockLevel.one, weight: 55),
      (level: BlockLevel.two, weight: 30),
      (level: BlockLevel.three, weight: 12),
      (level: BlockLevel.four, weight: 3),
      (level: BlockLevel.five, weight: 1),
    ];
  }
}
