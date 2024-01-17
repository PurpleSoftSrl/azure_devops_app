library file_detail;

import 'dart:typed_data';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

part 'components_file_detail.dart';
part 'controller_file_detail.dart';
part 'parameters_file_detail.dart';
part 'screen_file_detail.dart';

class FileDetailPage extends StatelessWidget {
  const FileDetailPage();

  static const _smartphoneParameters = _FileDetailParameters();
  static const _tabletParameters = _FileDetailParameters();

  @override
  Widget build(BuildContext context) {
    final args = AppRouter.getFileDetailArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return AppBasePage(
      initState: () => _FileDetailController._(apiService, args),
      smartphone: (ctrl) => _FileDetailScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _FileDetailScreen(ctrl, _tabletParameters),
    );
  }
}
