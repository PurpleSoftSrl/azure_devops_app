import 'package:azure_devops/src/screens/commit_detail/base_commit_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Mock commit is taken from [AzureApiServiceMock.getCommitDetail]
void main() {
  testWidgets(
    'Commit detail page shows all the details',
    (t) async {
      final detailPage = AzureApiServiceInherited(
        apiService: AzureApiServiceMock(),
        child: MaterialApp(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => CommitDetailPage(),
            settings: RouteSettings(
              arguments: (commitId: '123456789', project: 'TestProject', repository: 'test_repo'),
            ),
          ),
        ),
      );

      await t.pumpWidget(detailPage);
      await t.pump();

      // commit info
      expect(find.text('TestProject'), findsOneWidget);
      expect(find.text('test_repo'), findsOneWidget);
      expect(find.text('Test commit message'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);

      // edited files details
      expect(find.text('5 edited files'), findsOneWidget);
      expect(find.text('3 added files'), findsOneWidget);
      expect(find.text('1 deleted file'), findsOneWidget);
    },
  );
}
