library login;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

part 'components_login.dart';
part 'controller_login.dart';
part 'parameters_login.dart';
part 'screen_login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage();

  static const _smartphoneParameters = _LoginParameters();
  static const _tabletParameters = _LoginParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _LoginController(apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _LoginScreen(ctrl, _smartphoneParameters)
          : _LoginScreen(ctrl, _tabletParameters),
    );
  }
}
