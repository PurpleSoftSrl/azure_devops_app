import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/file_detail/base_file_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'api_service_mock.dart';

/// Mock file is taken from [AzureApiServiceMock.getFileDetail]
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Page building test', (t) async {
    final app = AzureApiServiceInherited(
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

    await t.pumpWidget(app);
    await t.pumpAndSettle();

    expect(find.byType(FileDetailPage), findsOneWidget);
  });
}
