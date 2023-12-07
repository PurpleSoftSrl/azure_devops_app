import 'package:azure_devops/src/screens/pipeline_detail/base_pipeline_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'api_service_mock.dart';

/// Mock pipeline is taken from [AzureApiServiceMock.getPipeline]
void main() {
  setUp(() => VisibilityDetectorController.instance.updateInterval = Duration.zero);

  testWidgets(
    'Pipeline detail page shows all the details',
    (t) async {
      final detailPage = AzureApiServiceInherited(
        apiService: AzureApiServiceMock(),
        child: MaterialApp(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => PipelineDetailPage(),
            settings: RouteSettings(
              arguments: (id: 1234, project: 'TestProject'),
            ),
          ),
        ),
      );

      await t.pumpWidget(detailPage);

      await t.pump();

      // pipeline info
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('now'), findsOneWidget);
      expect(find.text('TestProject'), findsOneWidget);
      expect(find.text('test_repo'), findsOneWidget);

      // commit info
      expect(find.text('Test commit message'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
      expect(find.text('Branch: test_branch', findRichText: true), findsOneWidget);

      // build info
      expect(find.text('Id:  1234', findRichText: true), findsOneWidget);
      expect(find.text('Number:  5678', findRichText: true), findsOneWidget);
    },
  );
}
