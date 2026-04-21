import 'block_entity.dart';
import 'cell_entity.dart';

class BoardEntity {
  BoardEntity({required this.size, required List<CellEntity> cells})
    : cells = List<CellEntity>.unmodifiable(cells);

  factory BoardEntity.empty({int size = 5}) {
    final List<CellEntity> cells = <CellEntity>[];
    for (int row = 0; row < size; row++) {
      for (int column = 0; column < size; column++) {
        cells.add(CellEntity(row: row, column: column));
      }
    }

    return BoardEntity(size: size, cells: cells);
  }

  final int size;
  final List<CellEntity> cells;

  bool get hasEmptyCell => cells.any((CellEntity cell) => cell.isEmpty);

  int get occupiedCellCount =>
      cells.where((CellEntity cell) => !cell.isEmpty).length;

  int get totalBlockLevels => cells.fold<int>(
    0,
    (int total, CellEntity cell) => total + (cell.block?.level.value ?? 0),
  );

  int get highestBlockLevel =>
      cells.fold<int>(0, (int highest, CellEntity cell) {
        final int level = cell.block?.level.value ?? 0;
        return level > highest ? level : highest;
      });

  bool isInside(int row, int column) {
    return row >= 0 && row < size && column >= 0 && column < size;
  }

  CellEntity cellAt(int row, int column) {
    _assertInside(row, column);
    return cells[_toIndex(row, column)];
  }

  bool isCellEmpty(int row, int column) {
    return cellAt(row, column).isEmpty;
  }

  Iterable<CellEntity> neighborsOf(int row, int column) sync* {
    const List<(int, int)> offsets = <(int, int)>[
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ];

    for (final (int rowOffset, int columnOffset) in offsets) {
      final int nextRow = row + rowOffset;
      final int nextColumn = column + columnOffset;
      if (isInside(nextRow, nextColumn)) {
        yield cellAt(nextRow, nextColumn);
      }
    }
  }

  BoardEntity placeBlock({
    required int row,
    required int column,
    required BlockEntity block,
  }) {
    if (!isCellEmpty(row, column)) {
      throw StateError('Cannot place a block on an occupied cell.');
    }

    return setBlock(row: row, column: column, block: block);
  }

  BoardEntity clearBlock({required int row, required int column}) {
    return setBlock(row: row, column: column, block: null);
  }

  BoardEntity setBlock({
    required int row,
    required int column,
    required BlockEntity? block,
  }) {
    _assertInside(row, column);

    final List<CellEntity> updatedCells = List<CellEntity>.from(cells);
    final int index = _toIndex(row, column);

    updatedCells[index] = updatedCells[index].copyWith(
      block: block,
      clearBlock: block == null,
    );

    return BoardEntity(size: size, cells: updatedCells);
  }

  int _toIndex(int row, int column) {
    return row * size + column;
  }

  void _assertInside(int row, int column) {
    if (!isInside(row, column)) {
      throw RangeError('Cell ($row, $column) is outside the board.');
    }
  }
}
