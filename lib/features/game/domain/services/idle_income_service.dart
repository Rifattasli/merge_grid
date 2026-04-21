import '../entities/board_entity.dart';

class IdleIncomeService {
  const IdleIncomeService({
    this.maxOfflineSeconds = 14400,
    this.progressUnitsPerCoin = 15,
  });

  final int maxOfflineSeconds;
  final int progressUnitsPerCoin;

  int calculateCoins({
    required BoardEntity board,
    required DateTime from,
    required DateTime to,
  }) {
    final int elapsedSeconds = to.difference(from).inSeconds;
    if (elapsedSeconds <= 0) {
      return 0;
    }

    final int boundedSeconds = elapsedSeconds > maxOfflineSeconds
        ? maxOfflineSeconds
        : elapsedSeconds;

    final int totalLevels = board.totalBlockLevels;
    if (totalLevels == 0) {
      return 0;
    }

    return (totalLevels * boundedSeconds) ~/ progressUnitsPerCoin;
  }
}
