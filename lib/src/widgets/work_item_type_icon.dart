import 'package:azure_devops/src/models/processes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WorkItemTypeIcon extends StatelessWidget {
  const WorkItemTypeIcon({this.type});

  final WorkItemType? type;

  @override
  Widget build(BuildContext context) {
    return type == null || type == WorkItemType.all
        ? const SizedBox()
        : SvgPicture.network(
            'https://tfsprodweu2.visualstudio.com/_apis/wit/workItemIcons/${type!.icon}?color=${type!.color}&v=2',
            width: 20,
          );
  }
}
