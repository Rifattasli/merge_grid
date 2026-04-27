import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/block_entity.dart';
import '../../domain/entities/board_entity.dart';
import '../board_layout.dart';
import '../../presentation/controllers/game_controller.dart';
import '../../presentation/models/game_feedback.dart';

class BoardComponent extends PositionComponent with TapCallbacks {
  BoardComponent({required this.gameController, required this.gridSize}) {
    anchor = Anchor.topLeft;
  }

  final GameController gameController;
  final int gridSize;

  static const double _cornerRadius = 18;

  final List<_PulseAnimation> _pulses = <_PulseAnimation>[];
  final List<_FloatingLabelAnimation> _floatingLabels =
      <_FloatingLabelAnimation>[];
  int _lastHandledFeedbackSequence = 0;

  final Paint _boardPaint = Paint()..color = const Color(0xFFD6B38D);
  final Paint _emptyCellPaint = Paint()..color = const Color(0xFFF8EAD7);
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

    final BoardLayout layout = _layout;

    final RRect boardRect = RRect.fromRectAndRadius(
      layout.boardRect,
      const Radius.circular(_cornerRadius),
    );
    canvas.drawRRect(boardRect, _boardPaint);

    final BoardEntity board = gameController.session.board;
    for (final cell in board.cells) {
      final Rect cellRect = layout.cellRect(row: cell.row, column: cell.column);
      final Rect baseBlockRect = layout.blockRect(
        row: cell.row,
        column: cell.column,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          cellRect,
          Radius.circular(layout.cellExtent * 0.18),
        ),
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
      final double scaleLimit =
          (cellRect.width - 1) / math.max(baseBlockRect.width, 1);
      final Rect scaledRect = _scaledRect(
        baseBlockRect,
        math.min(1 + (0.05 * pulseValue), scaleLimit),
      );
      final Color blockColor = _blockColor(block.level.value);
      final Paint blockPaint = Paint()..color = blockColor;
      final double blockRadius = scaledRect.width * 0.22;
      final double highlightInset = math.max(2, scaledRect.width * 0.05);
      final double highlightHeight = scaledRect.height * 0.36;
      final TextPaint levelTextPaint = TextPaint(
        style: TextStyle(
          color: const Color(0xFF5B4334),
          fontSize: (scaledRect.height * 0.34).clamp(15.0, 22.0),
          fontWeight: FontWeight.w800,
        ),
      );
      final TextPaint valueTextPaint = TextPaint(
        style: TextStyle(
          color: const Color(0xFF8A6A55),
          fontSize: (scaledRect.height * 0.14).clamp(8.0, 10.0),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      );

      canvas.drawShadow(
        Path()..addRRect(
          RRect.fromRectAndRadius(scaledRect, Radius.circular(blockRadius)),
        ),
        const Color(0x3D815438),
        6 + (4 * pulseValue),
        false,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, Radius.circular(blockRadius)),
        blockPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            scaledRect.left + highlightInset,
            scaledRect.top + highlightInset,
            scaledRect.width - (highlightInset * 2),
            highlightHeight,
          ),
          Radius.circular(blockRadius * 0.85),
        ),
        Paint()..color = const Color(0xFFFFF9F0).withValues(alpha: 0.26),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, Radius.circular(blockRadius)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Colors.white.withValues(alpha: 0.28),
      );
      if (pulseValue > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            _scaledRect(scaledRect, 1 + (0.06 * pulseValue)),
            Radius.circular(blockRadius * 1.1),
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = pulseColor.withValues(alpha: 0.40 * pulseValue),
        );
      }

      levelTextPaint.render(
        canvas,
        '${block.level.value}',
        Vector2(
          scaledRect.center.dx,
          scaledRect.center.dy - (scaledRect.height * 0.08),
        ),
        anchor: Anchor.center,
      );
      valueTextPaint.render(
        canvas,
        'TIER',
        Vector2(
          scaledRect.center.dx,
          scaledRect.center.dy + (scaledRect.height * 0.19),
        ),
        anchor: Anchor.center,
      );
    }

    _renderFloatingLabels(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    final Vector2 localPosition = event.localPosition;
    final BoardLayout layout = _layout;
    final Rect playableRect = layout.playableRect;
    if (!playableRect.contains(Offset(localPosition.x, localPosition.y))) {
      return;
    }

    final double step = layout.step;
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
          color: const Color(0xFFEA7A63),
        ),
      );
    }
    if (feedback.coinsGained > 0) {
      _floatingLabels.add(
        _FloatingLabelAnimation(
          row: feedback.row,
          column: feedback.column,
          label: '+${feedback.coinsGained} coin',
          color: const Color(0xFFF2C96B),
          verticalOffset: 14,
        ),
      );
    }
  }

  BoardLayout get _layout => BoardLayout.square(
    boardExtent: math.min(size.x, size.y),
    gridSize: gridSize,
  );

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
    final BoardLayout layout = _layout;
    for (final _FloatingLabelAnimation label in _floatingLabels) {
      final double progress = (label.elapsed / label.duration).clamp(0, 1);
      final double opacity = 1 - progress;
      final Rect cellRect = layout.cellRect(
        row: label.row,
        column: label.column,
      );
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
      Color(0xFFF2C96B),
      Color(0xFFF4B183),
      Color(0xFFEA7A63),
      Color(0xFFDD8E72),
      Color(0xFF8BB79B),
      Color(0xFF5A9A9C),
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
