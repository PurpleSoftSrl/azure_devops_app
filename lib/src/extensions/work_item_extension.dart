import 'dart:ui';

import 'package:azure_devops/src/models/work_item.dart';

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
}
