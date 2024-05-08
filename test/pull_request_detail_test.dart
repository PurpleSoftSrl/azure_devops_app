import 'package:azure_devops/src/screens/pull_request_detail/base_pull_request_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'api_service_mock.dart';

/// Mock pull request is taken from [AzureApiServiceMock.getPullRequest]
void main() {
  setUp(() => VisibilityDetectorController.instance.updateInterval = Duration.zero);

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Page building test',
    (t) async {
      final app = AzureApiServiceInherited(
        apiService: AzureApiServiceMock(),
        child: StorageServiceInherited(
          storageService: StorageServiceMock(),
          child: MaterialApp(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => PullRequestDetailPage(),
              settings: RouteSettings(
                arguments: (id: 1234, project: 'TestProject', repository: 'TestRepo'),
              ),
            ),
          ),
        ),
      );

      await t.pumpWidget(app);

      await t.pump();

      expect(find.byType(PullRequestDetailPage), findsOneWidget);
    },
  );
}
