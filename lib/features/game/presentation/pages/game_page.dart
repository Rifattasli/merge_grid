import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/app_widgets.dart';
import '../../../../core/services/ads_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board_view.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/next_block_preview.dart';
import '../widgets/pause_overlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const double _pagePadding = 12;
  static const double _boardFramePadding = 8;
  static const double _boardFrameRadius = 28;
  static const double _buttonHeight = 48;
  static const double _bottomRowHeight = 78;
  static const double _sectionSpacing = 10;

  bool _isPaused = false;
  bool _isHandlingAdFlow = false;

  @override
  Widget build(BuildContext context) {
    final GameController gameController = context.read<GameController>();
    final AdsService adsService = context.read<AdsService>();
    final AnalyticsService analyticsService = context.read<AnalyticsService>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
          ),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text('Merge Grid'),
      ),
      body: AppBackground(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _pagePadding,
                _pagePadding,
                _pagePadding,
                10,
              ),
              child: Column(
                children: [
                  Selector<
                    GameController,
                    ({
                      int score,
                      int bestScore,
                      int coins,
                      bool hasIdleCoinFlow,
                    })
                  >(
                    selector: (_, GameController controller) => (
                      score: controller.session.score,
                      bestScore: controller.bestScore,
                      coins: controller.displayedCoins,
                      hasIdleCoinFlow: controller.hasIdleCoinFlow,
                    ),
                    builder: (context, hudData, _) {
                      return GameHud(
                        score: hudData.score,
                        bestScore: hudData.bestScore,
                        coins: hudData.coins,
                        hasIdleCoinFlow: hudData.hasIdleCoinFlow,
                        onPausePressed: () {
                          setState(() {
                            _isPaused = true;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: _sectionSpacing),
                  Expanded(
                    child: Center(
                      child: AppPanel(
                        radius: _boardFrameRadius,
                        padding: const EdgeInsets.all(_boardFramePadding),
                        backgroundColor: AppColors.warmCream.withValues(
                          alpha: 0.94,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0C6A8),
                              borderRadius: BorderRadius.circular(
                                _boardFrameRadius - 6,
                              ),
                            ),
                            padding: const EdgeInsets.all(_boardFramePadding),
                            child: GameBoardView(controller: gameController),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _sectionSpacing),
                  Selector<GameController, bool>(
                    selector: (_, GameController controller) =>
                        controller.session.isGameOver,
                    builder: (context, showGameOver, _) {
                      return Text(
                        showGameOver
                            ? 'No moves left for this run.'
                            : 'Tap an empty cell to place the next block.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.cocoaSoft,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: _sectionSpacing),
                  SizedBox(
                    height: _bottomRowHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Selector<GameController, int>(
                            selector: (_, GameController controller) =>
                                controller.session.nextBlock.level.value,
                            builder: (context, level, _) {
                              return NextBlockPreview(level: level);
                            },
                          ),
                        ),
                        const SizedBox(width: _sectionSpacing),
                        SizedBox(
                          width: 118,
                          height: _buttonHeight,
                          child: Selector<GameController, bool>(
                            selector: (_, GameController controller) =>
                                controller.session.isGameOver,
                            builder: (context, showGameOver, _) {
                              return ElevatedButton(
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
                              );
                            },
                          ),
                        ),
                      ],
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
            Selector<
              GameController,
              ({
                bool showGameOver,
                int score,
                int bestScore,
                int coins,
                bool canContinue,
              })
            >(
              selector: (_, GameController controller) => (
                showGameOver: controller.session.isGameOver,
                score: controller.session.score,
                bestScore: controller.bestScore,
                coins: controller.displayedCoins,
                canContinue: controller.canContinueAfterGameOver,
              ),
              builder: (context, overlayData, _) {
                if (!overlayData.showGameOver) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: GameOverOverlay(
                    score: overlayData.score,
                    bestScore: overlayData.bestScore,
                    coins: overlayData.coins,
                    canContinue: overlayData.canContinue,
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
                );
              },
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
