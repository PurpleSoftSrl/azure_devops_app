import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/work_items/base_work_items.dart';
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

  testWidgets(
    'Page building test',
    (t) async {
      final app = MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        theme: mockTheme,
        home: StorageServiceInherited(
          storageService: StorageServiceMock(),
          child: AdsServiceWidget(
            ads: AdsServiceMock(),
            child: AzureApiServiceInherited(
              apiService: AzureApiServiceMock(),
              child: WorkItemsPage(),
            ),
          ),
        ),
      );

      await t.pumpWidget(app);

      await t.pump();

      expect(find.byType(WorkItemsPage), findsOneWidget);
    },
  );
}
