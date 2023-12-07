import 'package:azure_devops/src/screens/home/base_home.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen build test', (t) async {
    final homePage = MaterialApp(
      home: AzureApiServiceInherited(
        apiService: AzureApiServiceMock(),
        child: StorageServiceInherited(
          storageService: StorageServiceMock(),
          child: HomePage(),
        ),
      ),
    );

    await t.pumpWidget(homePage);
    await t.pump(Duration(seconds: 5));
    // await t.pumpAndSettle();
  });
}
