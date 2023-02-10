import 'package:azure_devops/src/screens/pipelines/base_pipelines.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Pipelines are sorted by status',
    (t) async {
      final pipelinesPage = MaterialApp(
        home: AzureApiServiceInherited(
          apiService: AzureApiServiceMock(),
          child: PipelinesPage(),
        ),
      );

      await t.pumpWidget(pipelinesPage);

      await t.pump();

      final tiles = find.textContaining('Test User');

      // running pipeline
      expect((t.widget(tiles.at(0)) as Text).data, 'Test User 2');

      // queued pipeline
      expect((t.widget(tiles.at(1)) as Text).data, 'Test User 3');

      // completed pipeline
      expect((t.widget(tiles.at(2)) as Text).data, 'Test User 1');
    },
  );
}
