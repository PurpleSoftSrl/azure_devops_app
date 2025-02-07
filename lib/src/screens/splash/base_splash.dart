library splash;

import 'dart:async';
import 'dart:io';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/msal_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:flutter/material.dart';

part 'components_splash.dart';
part 'controller_splash.dart';
part 'parameters_splash.dart';
part 'screen_splash.dart';

class SplashPage extends StatelessWidget {
  const SplashPage();

  static const _smartphoneParameters = _SplashParameters();
  static const _tabletParameters = _SplashParameters();

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      initState: () => _SplashController._(context.api),
      smartphone: (ctrl) => _SplashScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _SplashScreen(ctrl, _tabletParameters),
    );
  }
}
