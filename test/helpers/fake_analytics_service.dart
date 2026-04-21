import 'package:merge_grid/core/services/analytics_service.dart';

class FakeAnalyticsService implements AnalyticsService {
  final List<({String name, Map<String, Object?> parameters})> events =
      <({String name, Map<String, Object?> parameters})>[];

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    events.add((name: name, parameters: parameters));
  }
}
