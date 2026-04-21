enum BlockLevel {
  one(1),
  two(2),
  three(3),
  four(4),
  five(5),
  six(6);

  const BlockLevel(this.value);

  final int value;

  BlockLevel? get nextLevel {
    final int nextIndex = index + 1;
    if (nextIndex >= BlockLevel.values.length) {
      return null;
    }

    return BlockLevel.values[nextIndex];
  }

  int get scoreValue => value * 10;
}
