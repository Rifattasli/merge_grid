import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../flame/merge_game.dart';
import '../controllers/game_controller.dart';

class GameBoardView extends StatefulWidget {
  const GameBoardView({super.key, required this.controller});

  final GameController controller;

  @override
  State<GameBoardView> createState() => _GameBoardViewState();
}

class _GameBoardViewState extends State<GameBoardView> {
  late final MergeGame _game;

  @override
  void initState() {
    super.initState();
    _game = MergeGame(gameController: widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: GameWidget<MergeGame>(game: _game),
      ),
    );
  }
}
