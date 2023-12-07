import 'package:azure_devops/src/screens/project_detail/base_project_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('project detail page test', (t) async {
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

    expect(find.text('test name'), findsOneWidget);
    expect(find.text('member_2_name', findRichText: true), findsOneWidget);
  });
}
