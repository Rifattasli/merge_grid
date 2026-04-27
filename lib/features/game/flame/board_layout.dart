import 'dart:math' as math;

import 'package:flutter/material.dart';

class BoardLayout {
  BoardLayout._({
    required this.gridSize,
    required this.boardExtent,
    required this.outerPadding,
    required this.cellSpacing,
    required this.cellExtent,
    required this.blockInset,
  });

  factory BoardLayout.square({
    required double boardExtent,
    required int gridSize,
  }) {
    final double normalizedExtent = math.max(0, boardExtent);
    final double density = (normalizedExtent / 360).clamp(0.8, 1.25);
    final double outerPadding = 14 * density;
    final double cellSpacing = 8 * density;
    final double contentExtent = math.max(
      0,
      normalizedExtent - (outerPadding * 2),
    );
    final double cellExtent = math.max(
      0,
      (contentExtent - (cellSpacing * (gridSize - 1))) / gridSize,
    );
    final double blockInset = (cellExtent * 0.08).clamp(3.0, 6.0);

    return BoardLayout._(
      gridSize: gridSize,
      boardExtent: normalizedExtent,
      outerPadding: outerPadding,
      cellSpacing: cellSpacing,
      cellExtent: cellExtent,
      blockInset: blockInset,
    );
  }

  final int gridSize;
  final double boardExtent;
  final double outerPadding;
  final double cellSpacing;
  final double cellExtent;
  final double blockInset;

  double get step => cellExtent + cellSpacing;

  double get playableExtent =>
      (cellExtent * gridSize) + (cellSpacing * (gridSize - 1));

  Rect get boardRect => Rect.fromLTWH(0, 0, boardExtent, boardExtent);

  Rect get playableRect =>
      Rect.fromLTWH(outerPadding, outerPadding, playableExtent, playableExtent);

  Rect cellRect({required int row, required int column}) {
    final Rect rect = playableRect;
    return Rect.fromLTWH(
      rect.left + (column * step),
      rect.top + (row * step),
      cellExtent,
      cellExtent,
    );
  }

  Rect blockRect({required int row, required int column}) {
    return cellRect(row: row, column: column).deflate(blockInset);
  }
}
