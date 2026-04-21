import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.coins,
    required this.canContinue,
    required this.onContinuePressed,
    required this.onRestartPressed,
  });

  final int score;
  final int bestScore;
  final int coins;
  final bool canContinue;
  final VoidCallback onContinuePressed;
  final VoidCallback onRestartPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Game Over',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _ResultLine(label: 'Score', value: '$score'),
                const SizedBox(height: 8),
                _ResultLine(label: 'Best', value: '$bestScore'),
                const SizedBox(height: 8),
                _ResultLine(label: 'Coins', value: '$coins'),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EBD9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    canContinue
                        ? 'Watch a rewarded ad to continue this run once.'
                        : 'Continue has already been used for this run.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canContinue ? onContinuePressed : null,
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onRestartPressed,
                    child: const Text('New Game'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
