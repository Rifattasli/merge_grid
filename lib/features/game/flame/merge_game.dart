import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../presentation/controllers/game_controller.dart';
import 'components/board_component.dart';

class MergeGame extends FlameGame {
  MergeGame({required this.gameController});

  final GameController gameController;

  late final BoardComponent _boardComponent;
  int _lastFeedbackSequence = 0;

  @override
  Color backgroundColor() => const Color(0xFFF1DFC8);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _boardComponent = BoardComponent(
      gameController: gameController,
      gridSize: gameController.session.board.size,
    );
    add(_boardComponent);
    gameController.addListener(_handleControllerUpdated);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (!isLoaded) {
      return;
    }

    final double boardExtent = math.min(size.x, size.y);
    _boardComponent.size = Vector2.all(boardExtent);
    _boardComponent.position = Vector2(
      (size.x - boardExtent) / 2,
      (size.y - boardExtent) / 2,
    );
  }

  @override
  void onRemove() {
    gameController.removeListener(_handleControllerUpdated);
    super.onRemove();
  }

  void _handleControllerUpdated() {
    final feedback = gameController.latestFeedback;
    if (feedback == null || feedback.sequence == _lastFeedbackSequence) {
      return;
    }

    _lastFeedbackSequence = feedback.sequence;
    _boardComponent.handleFeedback(feedback);
  }
}
