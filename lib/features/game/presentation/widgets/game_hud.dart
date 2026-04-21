import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: _HudStatCard(
              label: 'Best',
              value: '$bestScore',
              accentColor: const Color(0xFF5E8B7E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HudStatCard(
              label: 'Coins',
              value: '$coins',
              accentColor: const Color(0xFFE0B83F),
              trailing: hasIdleCoinFlow
                  ? const _IdleCoinIndicator()
                  : const SizedBox(height: 16),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3E7D4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton.filledTonal(
              onPressed: onPausePressed,
              tooltip: 'Pause',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF3E7D4),
                foregroundColor: const Color(0xFF5A4A3C),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.18),
            const Color(0xFFFFF8EE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF7B6A58),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF3A2E24),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          trailing ?? const SizedBox(height: 16),
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
          const Icon(Icons.circle, size: 8, color: Color(0xFFE0B83F)),
          const SizedBox(width: 6),
          Text(
            'idle',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF9A7A17),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
