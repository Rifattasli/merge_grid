import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/app_widgets.dart';
import '../../../../app/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.settingsRoute);
                    },
                    icon: const Icon(Icons.settings_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface.withValues(
                        alpha: 0.88,
                      ),
                      foregroundColor: AppColors.cocoa,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(child: _HeroBoardPreview()),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Merge Grid',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Merge matching blocks, grow your board, and chase that just-one-more-turn feeling.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        backgroundColor: AppColors.surface.withValues(
                          alpha: 0.94,
                        ),
                        child: Row(
                          children: [
                            const _QuickFact(
                              icon: Icons.grid_view_rounded,
                              label: '5x5 Board',
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              width: 1,
                              height: 24,
                              color: AppColors.outline,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const _QuickFact(
                              icon: Icons.auto_awesome_rounded,
                              label: 'Relaxing Merge',
                            ),
                            const Spacer(),
                          /*  Text(
                              'Cozy puzzle',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: 'Play',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.gameRoute);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSecondaryButton(
                  label: 'Preview Result Screen',
                  icon: Icons.emoji_events_rounded,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.resultRoute);
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

class _HeroBoardPreview extends StatelessWidget {
  const _HeroBoardPreview();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppPanel(
        padding: const EdgeInsets.all(AppSpacing.md),
        radius: AppRadii.lg,
        backgroundColor: AppColors.warmCream.withValues(alpha: 0.92),
        child: SizedBox(
          width: 170,
          height: 170,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 25,
            itemBuilder: (context, index) {
              final List<Color> colors = <Color>[
                AppColors.butter,
                AppColors.peach,
                AppColors.coral,
                AppColors.sage,
                AppColors.teal,
              ];
              final bool filled = index % 2 == 0 || index == 7 || index == 18;
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: filled
                      ? colors[index % colors.length]
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: filled
                      ? const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: filled
                    ? Center(
                        child: Text(
                          '${(index % 4) + 1}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.cocoa,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuickFact extends StatelessWidget {
  const _QuickFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.coral),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
