import 'package:azure_devops/src/screens/pipeline_detail/base_pipeline_detail.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'api_service_mock.dart';

/// Mock pipeline is taken from [AzureApiServiceMock.getPipeline]
void main() {
  setUp(() => VisibilityDetectorController.instance.updateInterval = Duration.zero);

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Page building test',
    (t) async {
      final app = AdsServiceWidget(
        ads: AdsServiceMock(),
        child: AzureApiServiceInherited(
          apiService: AzureApiServiceMock(),
          child: MaterialApp(
            theme: mockTheme,
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => PipelineDetailPage(),
              settings: RouteSettings(
                arguments: (id: 1234, project: 'TestProject'),
              ),
            ),
          ),
        ),
      );

      await t.pumpWidget(app);

      await t.pump();

      expect(find.byType(PipelineDetailPage), findsOneWidget);
    },
  );
}
