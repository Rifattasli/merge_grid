import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/app_widgets.dart';

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
      color: AppColors.scrim,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: AppPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              radius: AppRadii.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: AppColors.warmCream,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.coral,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Game Over',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'You built a solid run. Ready to squeeze out a few more merges?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ResultLine(label: 'Score', value: '$score'),
                  const SizedBox(height: AppSpacing.sm),
                  _ResultLine(label: 'Best', value: '$bestScore'),
                  const SizedBox(height: AppSpacing.sm),
                  _ResultLine(label: 'Coins', value: '$coins'),
                  const SizedBox(height: AppSpacing.lg),
                  AppPanel(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    backgroundColor: AppColors.surfaceAlt,
                    borderColor: AppColors.outline.withValues(alpha: 0.8),
                    child: Text(
                      canContinue
                          ? 'Watch a rewarded ad to continue this run once.'
                          : 'Continue has already been used for this run.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Continue',
                      icon: Icons.play_circle_fill_rounded,
                      onPressed: canContinue ? onContinuePressed : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: AppSecondaryButton(
                      label: 'New Game',
                      icon: Icons.refresh_rounded,
                      onPressed: onRestartPressed,
                    ),
                  ),
                ],
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmCream.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
