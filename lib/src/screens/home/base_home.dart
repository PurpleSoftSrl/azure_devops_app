library home;

import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'components_home.dart';
part 'controller_home.dart';
part 'parameters_home.dart';
part 'screen_home.dart';

class HomePage extends StatelessWidget {
  const HomePage();

  static const _smartphoneParameters = _HomeParameters(gridItemAspectRatio: 1.4);
  static const _tabletParameters = _HomeParameters(gridItemAspectRatio: 2.4, projectCardHeight: 60);

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _HomeController(apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _HomeScreen(ctrl, _smartphoneParameters)
          : _HomeScreen(ctrl, _tabletParameters),
    );
  }
}
