import 'package:azure_devops/src/screens/pipeline_logs/base_pipeline_logs.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pipeline logs page test', (t) async {
    final pipelineLogsPage = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => PipelineLogsPage(),
          settings: RouteSettings(
            arguments: (
              logId: 1,
              parentTaskId: 'parent task id test',
              pipelineId: 1,
              project: 'project test',
              taskId: 'task id test',
            ),
          ),
        ),
      ),
    );

    await t.pumpWidget(pipelineLogsPage);
    await t.pump();

    expect(find.text('log test', findRichText: true), findsOneWidget);
  });
}
