import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/file_detail/base_file_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Mock file is taken from
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('file detail page test', (t) async {
    final detailPage = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => FileDetailPage(),
          settings: RouteSettings(
            arguments: RepoDetailArgs(
              projectName: 'project name',
              repositoryName: 'repo name',
              filePath: 'path',
              branch: 'branch test',
            ),
          ),
        ),
      ),
    );

    await t.pumpWidget(detailPage);
    await t.pumpAndSettle();

    final target = find.text('path');
    expect(target, findsOneWidget);
  });
}
