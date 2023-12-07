import 'dart:developer';

import 'package:azure_devops/src/screens/member_detail/base_member_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_service_mock.dart';

/// Api [AzureApiServiceMock.getUserFromDescriptor]
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('member detail page test', (t) async {
    final memberPage = AzureApiServiceInherited(
      apiService: AzureApiServiceMock(),
      child: MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => MemberDetailPage(),
          settings: RouteSettings(
            arguments: '',
          ),
        ),
      ),
    );

    await t.pumpWidget(memberPage);
    await t.pumpAndSettle();

    expect(find.text('Name:  name test', findRichText: true), findsWidgets);
  });
}
