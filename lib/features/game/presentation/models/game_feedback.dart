class GameFeedback {
  const GameFeedback({
    required this.sequence,
    required this.row,
    required this.column,
    required this.scoreGained,
    required this.coinsGained,
    required this.highlightLevel,
    required this.mergeCount,
    required this.didTriggerGameOver,
  });

  final int sequence;
  final int row;
  final int column;
  final int scoreGained;
  final int coinsGained;
  final int highlightLevel;
  final int mergeCount;
  final bool didTriggerGameOver;
}
