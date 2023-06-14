import 'package:azure_devops/src/screens/pull_request_detail/base_pull_request_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Mock pull request is taken from [AzureApiServiceMock.getPullRequest]
void main() {
  testWidgets(
    'Pull request detail page shows all the details',
    (t) async {
      final detailPage = AzureApiServiceInherited(
        apiService: AzureApiServiceMock(),
        child: StorageServiceInherited(
          storageService: StorageServiceMock(),
          child: MaterialApp(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => PullRequestDetailPage(),
              settings: RouteSettings(
                arguments: (id: 1234, project: 'TestProject'),
              ),
            ),
          ),
        ),
      );

      await t.pumpWidget(detailPage);

      await t.pump();

      expect(find.text('Id:  1234', findRichText: true), findsOneWidget);
      expect(find.text('Created by:  Test User Creator', findRichText: true), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('now'), findsOneWidget);
      expect(find.text('TestProject'), findsOneWidget);
      expect(find.text('Test pull request title'), findsOneWidget);
      expect(find.text('From:  dev', findRichText: true), findsOneWidget);
      expect(find.text('To:  main', findRichText: true), findsOneWidget);
    },
  );
}
