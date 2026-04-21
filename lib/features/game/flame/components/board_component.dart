import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/block_entity.dart';
import '../../domain/entities/board_entity.dart';
import '../../presentation/controllers/game_controller.dart';
import '../../presentation/models/game_feedback.dart';

class BoardComponent extends PositionComponent with TapCallbacks {
  BoardComponent({required this.gameController, required this.gridSize});

  final GameController gameController;
  final int gridSize;

  static const double _gridPadding = 14;
  static const double _cellSpacing = 8;
  static const double _cornerRadius = 18;

  final List<_PulseAnimation> _pulses = <_PulseAnimation>[];
  final List<_FloatingLabelAnimation> _floatingLabels =
      <_FloatingLabelAnimation>[];
  int _lastHandledFeedbackSequence = 0;

  final Paint _boardPaint = Paint()..color = const Color(0xFFD4C4AF);
  final Paint _emptyCellPaint = Paint()..color = const Color(0xFFF6EEDF);
  final TextPaint _levelTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFF3E3025),
      fontSize: 22,
      fontWeight: FontWeight.w800,
    ),
  );
  final TextPaint _valueTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFF7A5F49),
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    ),
  );
  final TextPaint _floatingTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFF8EE),
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);

    for (final _PulseAnimation pulse in _pulses) {
      pulse.elapsed += dt;
    }
    _pulses.removeWhere((pulse) => pulse.elapsed >= pulse.duration);

    for (final _FloatingLabelAnimation label in _floatingLabels) {
      label.elapsed += dt;
    }
    _floatingLabels.removeWhere((label) => label.elapsed >= label.duration);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final RRect boardRect = RRect.fromRectAndRadius(
      Offset.zero & size.toSize(),
      const Radius.circular(_cornerRadius),
    );
    canvas.drawRRect(boardRect, _boardPaint);

    final BoardEntity board = gameController.session.board;
    for (final cell in board.cells) {
      final Rect cellRect = _cellRect(row: cell.row, column: cell.column);

      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(14)),
        _emptyCellPaint,
      );

      final BlockEntity? block = cell.block;
      if (block == null) {
        continue;
      }

      final double pulseValue = _pulseForCell(cell.row, cell.column);
      final Color pulseColor =
          _pulseColorForCell(cell.row, cell.column) ??
          _blockColor(block.level.value);
      final Rect scaledRect = _scaledRect(cellRect, 1 + (0.12 * pulseValue));
      final Color blockColor = _blockColor(block.level.value);
      final Paint blockPaint = Paint()..color = blockColor;

      canvas.drawShadow(
        Path()..addRRect(
          RRect.fromRectAndRadius(scaledRect, const Radius.circular(16)),
        ),
        Colors.black26,
        5 + (4 * pulseValue),
        false,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, const Radius.circular(16)),
        blockPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            scaledRect.left + 3,
            scaledRect.top + 3,
            scaledRect.width - 6,
            scaledRect.height * 0.38,
          ),
          const Radius.circular(14),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.16),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, const Radius.circular(16)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Colors.white.withValues(alpha: 0.28),
      );
      if (pulseValue > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            _scaledRect(scaledRect, 1 + (0.06 * pulseValue)),
            const Radius.circular(18),
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = pulseColor.withValues(alpha: 0.32 * pulseValue),
        );
      }

      _levelTextPaint.render(
        canvas,
        '${block.level.value}',
        Vector2(scaledRect.center.dx, scaledRect.center.dy - 6),
        anchor: Anchor.center,
      );
      _valueTextPaint.render(
        canvas,
        'TIER',
        Vector2(scaledRect.center.dx, scaledRect.center.dy + 13),
        anchor: Anchor.center,
      );
    }

    _renderFloatingLabels(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    final Vector2 localPosition = event.localPosition;
    final Rect playableRect = _playableRect();
    if (!playableRect.contains(Offset(localPosition.x, localPosition.y))) {
      return;
    }

    final double step = _cellExtent + _cellSpacing;
    final int column = ((localPosition.x - playableRect.left) / step)
        .floor()
        .clamp(0, gridSize - 1);
    final int row = ((localPosition.y - playableRect.top) / step).floor().clamp(
      0,
      gridSize - 1,
    );

    gameController.placeBlockAt(row: row, column: column);
  }

  void handleFeedback(GameFeedback feedback) {
    if (feedback.sequence <= _lastHandledFeedbackSequence) {
      return;
    }

    _lastHandledFeedbackSequence = feedback.sequence;
    _pulses.add(
      _PulseAnimation(
        row: feedback.row,
        column: feedback.column,
        color: _blockColor(feedback.highlightLevel),
      ),
    );

    if (feedback.scoreGained > 0) {
      _floatingLabels.add(
        _FloatingLabelAnimation(
          row: feedback.row,
          column: feedback.column,
          label: '+${feedback.scoreGained}',
          color: const Color(0xFFE77D4B),
        ),
      );
    }
    if (feedback.coinsGained > 0) {
      _floatingLabels.add(
        _FloatingLabelAnimation(
          row: feedback.row,
          column: feedback.column,
          label: '+${feedback.coinsGained} coin',
          color: const Color(0xFFE0B83F),
          verticalOffset: 14,
        ),
      );
    }
  }

  Rect _playableRect() {
    final double boardExtent =
        (_cellExtent * gridSize) + (_cellSpacing * (gridSize - 1));

    return Rect.fromLTWH(_gridPadding, _gridPadding, boardExtent, boardExtent);
  }

  Rect _cellRect({required int row, required int column}) {
    final Rect playableRect = _playableRect();
    final double step = _cellExtent + _cellSpacing;

    return Rect.fromLTWH(
      playableRect.left + (column * step),
      playableRect.top + (row * step),
      _cellExtent,
      _cellExtent,
    );
  }

  double get _cellExtent {
    final double contentExtent = math.min(size.x, size.y) - (_gridPadding * 2);
    return (contentExtent - (_cellSpacing * (gridSize - 1))) / gridSize;
  }

  double _pulseForCell(int row, int column) {
    double strongest = 0;
    for (final _PulseAnimation pulse in _pulses) {
      if (pulse.row != row || pulse.column != column) {
        continue;
      }

      final double progress = (pulse.elapsed / pulse.duration).clamp(0, 1);
      final double curved = math.sin(progress * math.pi);
      if (curved > strongest) {
        strongest = curved;
      }
    }

    return strongest;
  }

  Color? _pulseColorForCell(int row, int column) {
    Color? selectedColor;
    double strongest = 0;
    for (final _PulseAnimation pulse in _pulses) {
      if (pulse.row != row || pulse.column != column) {
        continue;
      }

      final double progress = (pulse.elapsed / pulse.duration).clamp(0, 1);
      final double curved = math.sin(progress * math.pi);
      if (curved > strongest) {
        strongest = curved;
        selectedColor = pulse.color;
      }
    }

    return selectedColor;
  }

  void _renderFloatingLabels(Canvas canvas) {
    for (final _FloatingLabelAnimation label in _floatingLabels) {
      final double progress = (label.elapsed / label.duration).clamp(0, 1);
      final double opacity = 1 - progress;
      final Rect cellRect = _cellRect(row: label.row, column: label.column);
      final Vector2 position = Vector2(
        cellRect.center.dx,
        cellRect.top - (30 * progress) - label.verticalOffset,
      );
      TextPaint(
        style: _floatingTextPaint.style.copyWith(
          color: label.color.withValues(alpha: opacity),
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
      ).render(canvas, label.label, position, anchor: Anchor.center);
    }
  }

  Rect _scaledRect(Rect rect, double scale) {
    final double width = rect.width * scale;
    final double height = rect.height * scale;
    return Rect.fromCenter(center: rect.center, width: width, height: height);
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
}

class _PulseAnimation {
  _PulseAnimation({
    required this.row,
    required this.column,
    required this.color,
  });

  final int row;
  final int column;
  final Color color;
  final double duration = 0.28;
  double elapsed = 0;
}

class _FloatingLabelAnimation {
  _FloatingLabelAnimation({
    required this.row,
    required this.column,
    required this.label,
    required this.color,
    this.verticalOffset = 0,
  });

  final int row;
  final int column;
  final String label;
  final Color color;
  final double verticalOffset;
  final double duration = 0.75;
  double elapsed = 0;
}
