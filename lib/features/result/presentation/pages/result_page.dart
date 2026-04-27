import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/app_widgets.dart';
import '../../../../app/router.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Summary')),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(),
                AppPanel(
                  radius: AppRadii.lg,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.warmCream,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.coral,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Great Run',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'A polished result screen preview for your next round loop.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const _ResultStatRow(
                        label: 'Score',
                        value: '12,480',
                        accent: AppColors.coral,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ResultStatRow(
                        label: 'Best block',
                        value: 'LVL 7',
                        accent: AppColors.sage,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ResultStatRow(
                        label: 'Coins earned',
                        value: '126',
                        accent: AppColors.butter,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppPanel(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        backgroundColor: AppColors.surfaceAlt,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              color: AppColors.teal,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'You cleared 4 merge chains and reached a new session milestone.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AppPrimaryButton(
                  label: 'Play Again',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.gameRoute);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSecondaryButton(
                  label: 'Back Home',
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      (route) => route.settings.name == AppRouter.homeRoute,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStatRow extends StatelessWidget {
  const _ResultStatRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.cocoa),
          ),
        ],
      ),
    );
  }
}
