import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';

class NextBlockPreview extends StatefulWidget {
  const NextBlockPreview({super.key, required this.level});

  final int level;

  @override
  State<NextBlockPreview> createState() => _NextBlockPreviewState();
}

class _NextBlockPreviewState extends State<NextBlockPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late Animation<double> _pulseAnimation;
  bool _showLevelChangeBadge = false;
  Timer? _badgeTimer;

  @override
  void initState() {
    super.initState();
    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(covariant NextBlockPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level == widget.level) {
      return;
    }

    _controller.forward(from: 0);
    setState(() {
      _showLevelChangeBadge = true;
    });
    _badgeTimer?.cancel();
    _badgeTimer = Timer(const Duration(milliseconds: 950), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _showLevelChangeBadge = false;
      });
    });
  }

  @override
  void dispose() {
    _badgeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color blockColor = _blockColor(widget.level);
    final ThemeData theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (BuildContext context, Widget? child) {
        final double pulseValue = _pulseAnimation.value;
        final double scale = 1 + (0.05 * math.sin(pulseValue * math.pi));

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.surface, AppColors.warmCream],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: blockColor.withValues(alpha: 0.28 + (0.2 * pulseValue)),
                width: 1.2,
              ),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: blockColor.withValues(
                    alpha: 0.12 + (0.18 * pulseValue),
                  ),
                  blurRadius: 14 + (8 * pulseValue),
                  spreadRadius: 0.5 + pulseValue,
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                _PreviewTile(level: widget.level, color: blockColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'NEXT BLOCK',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.cocoaSoft,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.18),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: Text(
                          'LVL ${widget.level}',
                          key: ValueKey<int>(widget.level),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.cocoa,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, -0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: _showLevelChangeBadge
                      ? Container(
                          key: const ValueKey<String>('next-level-badge'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: blockColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: blockColor.withValues(alpha: 0.32),
                            ),
                          ),
                          child: Text(
                            'NEW LVL',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _darken(blockColor, 0.28),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _blockColor(int level) {
    const List<Color> palette = <Color>[
      Color(0xFFE9C46A),
      Color(0xFFF4A261),
      Color(0xFFE76F51),
      Color(0xFFD45D79),
      Color(0xFF7D74D1),
      Color(0xFF4D83D6),
    ];

    return palette[(level - 1).clamp(0, palette.length - 1)];
  }

  Color _darken(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final double lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.level, required this.color});

  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 4,
            top: 4,
            right: 4,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$level',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.cocoa,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'LVL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.cocoaSoft,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
