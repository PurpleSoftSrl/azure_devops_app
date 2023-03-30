import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/login/base_login.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

void main() {
  testWidgets('Login with invalid token shows error alert', (t) async {
    final app = MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      home: AzureApiServiceInherited(
        apiService: AzureApiServiceMock(),
        child: LoginPage(),
      ),
    );

    await t.pumpWidget(app);

    final pageTitle = find.textContaining('Az DevOps');
    expect(pageTitle, findsOneWidget);

    final formField = find.byType(TextFormField);
    expect(formField, findsOneWidget);

    await t.enterText(formField, 'invalidToken');
    await t.testTextInput.receiveAction(TextInputAction.done);

    await t.pumpAndSettle();

    final errorAlert = find.byType(AlertDialog);
    expect(errorAlert, findsOneWidget);

    final errorWidget = t.widget(errorAlert) as AlertDialog;
    expect((errorWidget.title as Text).data, 'Login error');
  });

  testWidgets("Login with token without 'All organizations' shows 'Insert your organization' bottomsheet", (t) async {
    final app = MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      home: AzureApiServiceInherited(
        apiService: AzureApiServiceMock(),
        child: LoginPage(),
      ),
    );

    await t.pumpWidget(app);

    final pageTitle = find.textContaining('Az DevOps');
    expect(pageTitle, findsOneWidget);

    final formField = find.byType(TextFormField);
    expect(formField, findsOneWidget);

    await t.enterText(formField, 'singleOrgToken');
    await t.testTextInput.receiveAction(TextInputAction.done);

    await t.pumpAndSettle();

    final errorAlert = find.byType(BottomSheet);
    expect(errorAlert, findsOneWidget);

    final errorText = find.descendant(of: errorAlert, matching: find.textContaining('Insert your organization'));
    expect(errorText, findsOneWidget);
  });

  testWidgets("Login with valid token brings user to 'Choose project' page", (t) async {
    final app = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: StorageServiceInherited(
        storageService: StorageServiceMock(),
        child: MaterialApp(
          navigatorKey: AppRouter.navigatorKey,
          routes: AppRouter.routes,
          home: LoginPage(),
        ),
      ),
    );

    await t.pumpWidget(app);

    final pageTitle = find.textContaining('Az DevOps');
    expect(pageTitle, findsOneWidget);

    final formField = find.byType(TextFormField);
    expect(formField, findsOneWidget);

    await t.enterText(formField, 'validToken');
    await t.testTextInput.receiveAction(TextInputAction.done);

    await t.pumpAndSettle();

    final errorAlert = find.byType(AlertDialog);
    expect(errorAlert, findsNothing);

    final chooseProjectPageTitle = find.textContaining('Choose projects');
    expect(chooseProjectPageTitle, findsOneWidget);
  });
}
