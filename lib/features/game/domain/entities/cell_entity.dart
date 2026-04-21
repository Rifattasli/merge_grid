import 'block_entity.dart';

class CellEntity {
  const CellEntity({required this.row, required this.column, this.block});

  final int row;
  final int column;
  final BlockEntity? block;

  bool get isEmpty => block == null;

  CellEntity copyWith({BlockEntity? block, bool clearBlock = false}) {
    return CellEntity(
      row: row,
      column: column,
      block: clearBlock ? null : block ?? this.block,
    );
  }
}
