library home;

import 'dart:async';

import 'package:azure_devops/main.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/string_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/filters_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/purchase_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/project_card.dart';
import 'package:azure_devops/src/widgets/search_field.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:azure_devops/src/widgets/work_card.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    final storageService = StorageServiceInherited.of(context).storageService;
    final purchase = context.purchaseService;
    return AppBasePage(
      initState: () => _HomeController._(apiService, storageService, purchase),
      smartphone: (ctrl) => _HomeScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _HomeScreen(ctrl, _tabletParameters),
    );
  }
}
