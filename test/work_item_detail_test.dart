import 'package:azure_devops/src/screens/work_item_detail/base_work_item_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Mock work item is taken from [AzureApiServiceMock.getWorkItemDetail]
void main() {
  testWidgets(
    'Work item detail page shows all the details',
    (t) async {
      final detailPage = AzureApiServiceInherited(
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

      await t.pumpWidget(detailPage);

      await t.pump();

      expect(find.text('TestType'), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
      expect(find.text('Test User Creator'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('now'), findsOneWidget);
      expect(find.text('TestProject'), findsOneWidget);
      expect(find.text('Test work item title'), findsOneWidget);
      expect(find.text('Assigned to:  Test User Assignee', findRichText: true), findsOneWidget);
    },
  );
}
