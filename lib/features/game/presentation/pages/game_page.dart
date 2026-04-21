import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/ads_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board_view.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/pause_overlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _isPaused = false;
  bool _isHandlingAdFlow = false;

  @override
  Widget build(BuildContext context) {
    final GameController gameController = context.watch<GameController>();
    final AdsService adsService = context.read<AdsService>();
    final AnalyticsService analyticsService = context.read<AnalyticsService>();
    final bool showGameOver = gameController.session.isGameOver;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text('Game'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GameHud(
                    score: gameController.session.score,
                    bestScore: gameController.bestScore,
                    coins: gameController.displayedCoins,
                    hasIdleCoinFlow: gameController.hasIdleCoinFlow,
                    onPausePressed: () {
                      setState(() {
                        _isPaused = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Next block: Level ${gameController.session.nextBlock.level.value}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5A4A3C),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5D8C6),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 16,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: GameBoardView(controller: gameController),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    showGameOver
                        ? 'No moves left for this run.'
                        : 'Tap an empty cell to place the next block.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF6B5B4B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isHandlingAdFlow
                          ? null
                          : () {
                              unawaited(
                                _startNewGame(
                                  gameController: gameController,
                                  adsService: adsService,
                                  analyticsService: analyticsService,
                                  fromCompletedRun: showGameOver,
                                ),
                              );
                            },
                      child: const Text('New Game'),
                    ),
                  ),
                ],
              ),
            ),
            if (_isPaused)
              Positioned.fill(
                child: PauseOverlay(
                  onResumePressed: () {
                    setState(() {
                      _isPaused = false;
                    });
                  },
                  onRestartPressed: () {
                    unawaited(
                      _startNewGame(
                        gameController: gameController,
                        adsService: adsService,
                        analyticsService: analyticsService,
                        fromCompletedRun: false,
                      ),
                    );
                  },
                ),
              ),
            if (showGameOver)
              Positioned.fill(
                child: GameOverOverlay(
                  score: gameController.session.score,
                  bestScore: gameController.bestScore,
                  coins: gameController.displayedCoins,
                  canContinue: gameController.canContinueAfterGameOver,
                  onContinuePressed: _isHandlingAdFlow
                      ? () {}
                      : () {
                          unawaited(
                            _handleRewardedContinue(
                              gameController: gameController,
                              adsService: adsService,
                              analyticsService: analyticsService,
                            ),
                          );
                        },
                  onRestartPressed: () {
                    unawaited(
                      _startNewGame(
                        gameController: gameController,
                        adsService: adsService,
                        analyticsService: analyticsService,
                        fromCompletedRun: true,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRewardedContinue({
    required GameController gameController,
    required AdsService adsService,
    required AnalyticsService analyticsService,
  }) async {
    setState(() {
      _isHandlingAdFlow = true;
    });

    if (adsService.isRewardedContinueAdReady) {
      unawaited(
        analyticsService.logEvent(
          'rewarded_continue_shown',
          parameters: <String, Object?>{
            'score': gameController.session.score,
            'turn_count': gameController.session.turnCount,
          },
        ),
      );
    }

    final bool didEarnReward = await adsService.showRewardedContinueAd();
    if (!mounted) {
      return;
    }

    setState(() {
      _isHandlingAdFlow = false;
    });

    if (didEarnReward && gameController.continueAfterGameOver()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Continue unlocked. One cell was cleared.'),
        ),
      );
      return;
    }

    final String message = adsService.isRewardedContinueAdReady
        ? 'Reward not earned. The run stays finished.'
        : 'Continue ad is not available right now.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startNewGame({
    required GameController gameController,
    required AdsService adsService,
    required AnalyticsService analyticsService,
    required bool fromCompletedRun,
  }) async {
    if (_isHandlingAdFlow) {
      return;
    }

    setState(() {
      _isHandlingAdFlow = true;
    });

    final bool didShowInterstitial = await adsService
        .showInterstitialOnDemand();
    if (didShowInterstitial) {
      unawaited(
        analyticsService.logEvent(
          'interstitial_shown',
          parameters: <String, Object?>{
            'score': gameController.session.score,
            'turn_count': gameController.session.turnCount,
            'from_completed_run': fromCompletedRun,
          },
        ),
      );
    }

    if (!mounted) {
      return;
    }

    gameController.startNewGame();
    setState(() {
      _isPaused = false;
      _isHandlingAdFlow = false;
    });
  }
}
