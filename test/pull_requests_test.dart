import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/pull_requests/base_pull_requests.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Mock pull requests are taken from [AzureApiServiceMock.getPullRequests]
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Page building test',
    (t) async {
      final app = MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        theme: mockTheme,
        home: StorageServiceInherited(
          storageService: StorageServiceMock(),
          child: AzureApiServiceInherited(
            apiService: AzureApiServiceMock(),
            child: PullRequestsPage(),
          ),
        ),
      );

      await t.pumpWidget(app);

      await t.pump();

      expect(find.byType(PullRequestsPage), findsOneWidget);
    },
  );

  testWidgets(
    'Pull requests are visible, with their title, creator and repository and are sorted by creation date',
    (t) async {
      final workitemsPage = MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        theme: mockTheme,
        home: StorageServiceInherited(
          storageService: StorageServiceMock(),
          child: AzureApiServiceInherited(
            apiService: AzureApiServiceMock(),
            child: PullRequestsPage(),
          ),
        ),
      );

      await t.pumpWidget(workitemsPage);

      await t.pump();

      final titles = find.textContaining('Pull request title');
      final creators = find.textContaining('Test User');
      final repos = find.textContaining('Repository name');

      // most recently created pull request
      expect((t.widget(titles.at(0)) as Text).data, 'Pull request title 3');
      expect((t.widget(creators.at(0)) as Text).data, '!3 Test User 3');
      expect((t.widget(repos.at(0)) as Text).data, 'Repository name 3');

      // second most recently created pull request
      expect((t.widget(titles.at(1)) as Text).data, 'Pull request title 2');
      expect((t.widget(creators.at(1)) as Text).data, '!2 Test User 2');
      expect((t.widget(repos.at(1)) as Text).data, 'Repository name 2');

      // least recently created pull request
      expect((t.widget(titles.at(2)) as Text).data, 'Pull request title 1');
      expect((t.widget(creators.at(2)) as Text).data, '!1 Test User 1');
      expect((t.widget(repos.at(2)) as Text).data, 'Repository name 1');
    },
  );
}
