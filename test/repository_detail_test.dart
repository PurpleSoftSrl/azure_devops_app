import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/repository_detail/base_repository_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'api_service_mock.dart';

/// Mock repository items are taken from [AzureApiServiceMock.getRepositoryItems]
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Page building test', (t) async {
    final app = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: MaterialApp(
        theme: mockTheme,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => RepositoryDetailPage(),
          settings: RouteSettings(
            arguments: RepoDetailArgs(
              projectName: '',
              repositoryName: '',
            ),
          ),
        ),
      ),
    );

    await t.pumpWidget(app);
    await t.pump();

    expect(find.byType(RepositoryDetailPage), findsOneWidget);
  });
}
