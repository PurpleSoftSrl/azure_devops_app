import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/work_items/base_work_items.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Work items are visible, with their title, id and project',
    (t) async {
      final workitemsPage = MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        home: StorageServiceInherited(
          storageService: StorageServiceMock(),
          child: AzureApiServiceInherited(
            apiService: AzureApiServiceMock(),
            child: WorkItemsPage(),
          ),
        ),
      );

      await t.pumpWidget(workitemsPage);

      await t.pump();

      final titles = find.textContaining('Work item title');
      final ids = find.textContaining('#');
      final projects = find.textContaining('Project ');

      // first work item
      expect((t.widget(titles.at(0)) as Text).data, 'Work item title 1');
      expect((t.widget(ids.at(0)) as Text).data, '#1');
      expect((t.widget(projects.at(0)) as Text).data, 'Project 1');

      // second work item
      expect((t.widget(titles.at(1)) as Text).data, 'Work item title 2');
      expect((t.widget(ids.at(1)) as Text).data, '#2');
      expect((t.widget(projects.at(1)) as Text).data, 'Project 2');

      // third work item
      expect((t.widget(titles.at(2)) as Text).data, 'Work item title 3');
      expect((t.widget(ids.at(2)) as Text).data, '#3');
      expect((t.widget(projects.at(2)) as Text).data, 'Project 3');
    },
  );
}
