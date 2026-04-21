import 'package:flutter_test/flutter_test.dart';

import 'package:merge_grid/app/app.dart';
import 'helpers/fake_ads_service.dart';
import 'helpers/fake_analytics_service.dart';
import 'helpers/fake_audio_service.dart';
import 'helpers/in_memory_storage_service.dart';

void main() {
  testWidgets('app opens home page and navigates to game page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MergeGridApp(
        storageService: InMemoryStorageService(),
        adsService: FakeAdsService(),
        audioService: FakeAudioService(),
        analyticsService: FakeAnalyticsService(),
      ),
    );

    expect(find.text('Merge Grid'), findsWidgets);
    expect(find.text('Play'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('New Game'), findsOneWidget);
    expect(
      find.text('Tap an empty cell to place the next block.'),
      findsOneWidget,
    );
  });
}
