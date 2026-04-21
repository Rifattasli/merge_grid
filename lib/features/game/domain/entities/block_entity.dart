import '../enums/block_level.dart';

class BlockEntity {
  const BlockEntity({required this.id, required this.level});

  final String id;
  final BlockLevel level;

  BlockEntity upgrade() {
    final BlockLevel? nextLevel = level.nextLevel;
    if (nextLevel == null) {
      throw StateError('Cannot upgrade block beyond ${level.name}.');
    }

    return BlockEntity(id: id, level: nextLevel);
  }
}
