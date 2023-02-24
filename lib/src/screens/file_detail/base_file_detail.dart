library file_detail;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:flutter/material.dart';

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
    final ctrl = _FileDetailController(apiService: apiService, args: args);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 600
          ? _FileDetailScreen(ctrl, _smartphoneParameters)
          : _FileDetailScreen(ctrl, _tabletParameters),
    );
  }
}
