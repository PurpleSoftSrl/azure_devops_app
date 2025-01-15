library choose_subscription;

import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/string_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/purchase_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:flutter/material.dart';

part 'components_choose_subscription.dart';
part 'controller_choose_subscription.dart';
part 'screen_choose_subscription.dart';

typedef _ChooseSubscriptionParameters = ();

class ChooseSubscriptionPage extends StatelessWidget {
  const ChooseSubscriptionPage();

  static const _ChooseSubscriptionParameters _smartphoneParameters = ();
  static const _ChooseSubscriptionParameters _tabletParameters = ();

  @override
  Widget build(BuildContext context) {
    final purchase = context.purchaseService;
    return AppBasePage(
      initState: () => _ChooseSubscriptionController._(purchase),
      smartphone: (ctrl) => _ChooseSubscriptionScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _ChooseSubscriptionScreen(ctrl, _tabletParameters),
    );
  }
}
