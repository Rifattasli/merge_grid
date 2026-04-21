import '../entities/board_entity.dart';
import '../services/merge_rule_service.dart';

class ResolveMergeUseCase {
  const ResolveMergeUseCase(this._mergeRuleService);

  final MergeRuleService _mergeRuleService;

  MergeResolution call({
    required BoardEntity board,
    required int row,
    required int column,
  }) {
    return _mergeRuleService.resolve(board: board, row: row, column: column);
  }
}
