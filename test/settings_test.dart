import 'package:azure_devops/src/screens/settings/base_settings.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PackageInfo.setMockInitialValues(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
    buildSignature: '',
  );
  // TODO handle context injection
  testWidgets(
    'Settings pages build test',
    (t) async {
      final settingsPage = MaterialApp(
        home: AzureApiServiceInherited(
          apiService: AzureApiServiceMock(),
          child: StorageServiceInherited(
            storageService: StorageServiceMock(),
            child: SettingsPage(),
          ),
        ),
      );

      await t.pumpWidget(settingsPage);
      // await t.pump();
      await t.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      final target = find.text('Personal info');
      expect(target, findsOneWidget);
    },
  );
}
