import 'package:azure_devops/src/models/work_item.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';

extension WorkItemExt on WorkItem {
  Color get stateColor {
    switch (state) {
      case 'New':
        return Color.fromRGBO(178, 178, 178, 1);
      case 'Active':
        return Color.fromRGBO(52, 120, 198, 1);
      case 'Resolved':
        return Color.fromRGBO(52, 120, 198, 1);
      case 'Closed':
        return Color.fromRGBO(82, 152, 66, 1);
      case 'Removed':
        return Color.fromRGBO(52, 120, 198, .2);
      case 'To Do':
        return Color.fromRGBO(255, 255, 255, 1);
      case 'Done':
        return Color.fromRGBO(255, 255, 255, 1);
      case 'Approved':
        return Color.fromRGBO(255, 255, 255, 1);
      case 'All':
        return Color.fromRGBO(255, 255, 255, 0);
      default:
        return Color.fromRGBO(255, 255, 255, 1);
    }
  }

  static List<String> get allStates => [
        'All',
        'New',
        'Active',
        'Resolved',
        'Closed',
        'Removed',
        'To',
        'Done',
        'Approved',
      ];

  Icon get workItemTypeIcon {
    switch (workItemType) {
      case 'Bug':
        return Icon(DevOpsIcons.bug, color: Colors.red);
      case 'Epic':
        return Icon(DevOpsIcons.epic, color: Colors.orange);
      case 'Feature':
        return Icon(DevOpsIcons.feature, color: Colors.purple);
      case 'Issue':
        return Icon(DevOpsIcons.issue, color: Colors.pink);
      case 'Task':
        return Icon(DevOpsIcons.task, color: Colors.amber);
      case 'Test Case':
        return Icon(DevOpsIcons.testcase, color: Colors.grey);
      case 'User Story':
        return Icon(DevOpsIcons.userstory, color: Colors.lightBlue);
      case 'Product Backlog Item':
        return Icon(DevOpsIcons.task, color: Colors.amber);
      case 'All':
      default:
        return Icon(DevOpsIcons.userstory, color: Colors.transparent);
    }
  }
}
