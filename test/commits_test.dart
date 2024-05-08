import 'package:azure_devops/src/screens/commits/base_commits.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Page building test',
    (t) async {
      final app = MaterialApp(
        home: AzureApiServiceInherited(
          apiService: AzureApiServiceMock(),
          child: StorageServiceInherited(
            storageService: StorageServiceMock(),
            child: CommitsPage(),
          ),
        ),
      );

      await t.pumpWidget(app);

      await t.pump();

      expect(find.byType(CommitsPage), findsOneWidget);
    },
  );

  testWidgets(
    'Commits are sorted by date descending',
    (t) async {
      final commitsPage = MaterialApp(
        home: AzureApiServiceInherited(
          apiService: AzureApiServiceMock(),
          child: StorageServiceInherited(
            storageService: StorageServiceMock(),
            child: CommitsPage(),
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
    },
  );
}
