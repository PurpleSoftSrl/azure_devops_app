import 'package:azure_devops/src/screens/commit_detail/base_commit_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Mock commit is taken from [AzureApiServiceMock.getCommitDetail]
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Page building test',
    (t) async {
      final app = AzureApiServiceInherited(
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

      await t.pumpWidget(app);
      await t.pump();

      expect(find.byType(CommitDetailPage), findsOneWidget);
    },
  );
}
