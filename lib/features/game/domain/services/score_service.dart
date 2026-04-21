import 'merge_rule_service.dart';

class ScoreService {
  const ScoreService();

  int calculateMergeScore(MergeResolution resolution) {
    return resolution.steps.fold<int>(
      0,
      (int total, MergeStepResult step) =>
          total + (step.toLevel.scoreValue * step.consumedBlocks),
    );
  }
}
