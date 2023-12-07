import 'dart:developer';

import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/repository_detail/base_repository_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('repository detail page test', (t) async {
    final repoDetailPage = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: MaterialApp(
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
    await t.pumpWidget(repoDetailPage);
    await t.pump();

    expect(find.text('item 2', findRichText: true), findsWidgets);
  });
}
