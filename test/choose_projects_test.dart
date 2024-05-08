import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/choose_projects/base_choose_projects.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Page building test', (t) async {
    final app = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: StorageServiceInherited(
        storageService: StorageServiceMock(),
        child: MaterialApp(
          navigatorKey: AppRouter.navigatorKey,
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (ctx) => ChooseProjectsPage(),
            settings: RouteSettings(arguments: false),
          ),
        ),
      ),
    );

    await t.pumpWidget(app);

    await t.pump();

    expect(find.byType(ChooseProjectsPage), findsOneWidget);
  });
  testWidgets('All projects are selected by default', (t) async {
    final app = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: StorageServiceInherited(
        storageService: StorageServiceMock(),
        child: MaterialApp(
          navigatorKey: AppRouter.navigatorKey,
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (ctx) => ChooseProjectsPage(),
            settings: RouteSettings(arguments: false),
          ),
        ),
      ),
    );

    await t.pumpWidget(app);

    final pageTitle = find.textContaining('Choose projects');
    expect(pageTitle, findsOneWidget);

    await t.pumpAndSettle();

    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsWidgets);

    final checkboxes = t.widgetList<Checkbox>(checkboxFinder);
    for (final checkbox in checkboxes) {
      expect(checkbox.value, isTrue);
    }
  });
}
