import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.score,
    required this.bestScore,
    required this.coins,
    required this.hasIdleCoinFlow,
    required this.onPausePressed,
  });

  final int score;
  final int bestScore;
  final int coins;
  final bool hasIdleCoinFlow;
  final VoidCallback onPausePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _HudStatCard(
              label: 'Score',
              value: '$score',
              accentColor: const Color(0xFFEF9B57),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _HudStatCard(
              label: 'Best',
              value: '$bestScore',
              accentColor: const Color(0xFF5E8B7E),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _HudStatCard(
              label: 'Coins',
              value: '$coins',
              accentColor: AppColors.butter,
              trailing: hasIdleCoinFlow
                  ? const _IdleCoinIndicator()
                  : const SizedBox(height: 12),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton.filledTonal(
              onPressed: onPausePressed,
              tooltip: 'Pause',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceAlt,
                foregroundColor: AppColors.cocoa,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.all(10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.pause_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudStatCard extends StatelessWidget {
  const _HudStatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    this.trailing,
  });

  final String label;
  final String value;
  final Color accentColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.18),
            const Color(0xFFFFF8EE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.cocoaSoft,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.cocoa,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          trailing ?? const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _IdleCoinIndicator extends StatefulWidget {
  const _IdleCoinIndicator();

  @override
  State<_IdleCoinIndicator> createState() => _IdleCoinIndicatorState();
}

class _IdleCoinIndicatorState extends State<_IdleCoinIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.butter),
          const SizedBox(width: 4),
          Text(
            'idle',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.cocoaSoft,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
