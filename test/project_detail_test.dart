import 'package:azure_devops/src/screens/project_detail/base_project_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Mock details taken from [AzureApiServiceMock.getProjectTeams]
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Project detail page shows all project's informations", (t) async {
    final projectPage = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => ProjectDetailPage(),
          settings: RouteSettings(
            arguments: 'test name',
          ),
        ),
      ),
    );

    await t.pumpWidget(projectPage);
    await t.pumpAndSettle();

    expect(find.text('member_2_name', findRichText: true), findsOneWidget);
  });
}
