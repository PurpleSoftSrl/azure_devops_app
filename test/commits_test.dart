import 'package:azure_devops/src/screens/commits/base_commits.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'api_service_mock.dart';

void main() {
  setUp(() => VisibilityDetectorController.instance.updateInterval = Duration.zero);

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Page building test', (t) async {
    final app = MaterialApp(
      theme: mockTheme,
      home: AzureApiServiceWidget(
        api: AzureApiServiceMock(),
        child: AdsServiceWidget(
          ads: AdsServiceMock(),
          child: StorageServiceWidget(storage: StorageServiceMock(), child: CommitsPage()),
        ),
      ),
    );

    await t.pumpWidget(app);

    await t.pump();

    expect(find.byType(CommitsPage), findsOneWidget);
  });

  testWidgets('Commits are sorted by date descending', (t) async {
    final commitsPage = MaterialApp(
      theme: mockTheme,
      home: AzureApiServiceWidget(
        api: AzureApiServiceMock(),
        child: AdsServiceWidget(
          ads: AdsServiceMock(),
          child: StorageServiceWidget(storage: StorageServiceMock(), child: CommitsPage()),
        ),
      ),
    );

    await t.pumpWidget(commitsPage);

    await t.pump();

    final tiles = find.textContaining('Test User');

    // most recent commit
    expect((t.widget(tiles.at(0)) as Text).data, 'Test User 2');

    // queued pipeline
    expect((t.widget(tiles.at(1)) as Text).data, 'Test User 3');

    // least recent commit
    expect((t.widget(tiles.at(2)) as Text).data, 'Test User 1');
  });
}
