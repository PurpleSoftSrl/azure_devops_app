import 'package:azure_devops/src/screens/work_item_detail/base_work_item_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'api_service_mock.dart';

/// Mock work item is taken from [AzureApiServiceMock.getWorkItemDetail]
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
              builder: (_) => WorkItemDetailPage(),
              settings: RouteSettings(
                arguments: (project: 'TestProject', id: 1234),
              ),
            ),
          ),
        ),
      );

      await t.pumpWidget(app);

      await t.pump();

      expect(find.byType(WorkItemDetailPage), findsOneWidget);
    },
  );
}
