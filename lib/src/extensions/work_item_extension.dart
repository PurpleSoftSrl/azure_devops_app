import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/work_item.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:flutter/material.dart';

extension WorkItemExt on WorkItem {
  Color get stateColor {
    switch (fields.systemState) {
      case 'New':
        return Color.fromRGBO(178, 178, 178, 1);
      case 'Active':
        return Color.fromRGBO(52, 120, 198, 1);
      case 'Resolved':
        return Color.fromRGBO(52, 82, 255, 1);
      case 'Closed':
        return Color.fromRGBO(82, 152, 66, 1);
      case 'Removed':
        return Colors.red;
      case 'To Do':
        return Color.fromRGBO(255, 255, 255, 1);
      case 'Done':
        return Color.fromRGBO(82, 152, 66, .5);
      case 'Approved':
        return Color.fromRGBO(82, 152, 66, 1);
      case 'All':
        return Color.fromRGBO(255, 255, 255, 0);
      default:
        return AppRouter.rootNavigator!.context.colorScheme.onBackground;
    }
  }

  static List<String> get allStates => [
        'All',
        'New',
        'Active',
        'Resolved',
        'Closed',
        'Removed',
        'To Do',
        'Done',
        'Approved',
      ];

  static WorkItem withType(String type) => WorkItem(
        id: -1,
        fields: ItemFields(
          systemWorkItemType: type,
          systemState: '',
          systemTeamProject: '',
          systemTitle: '',
          systemChangedDate: DateTime.now(),
        ),
      );

  static WorkItem withState(String state) => WorkItem(
        id: -1,
        fields: ItemFields(
          systemWorkItemType: '',
          systemState: state,
          systemTeamProject: '',
          systemTitle: '',
          systemChangedDate: DateTime.now(),
        ),
      );
}

extension WorkItemDetailExt on WorkItemDetail {
  bool get canBeChanged =>
      fields.systemWorkItemType != 'Feedback Request' &&
      fields.systemWorkItemType != 'Feedback Response' &&
      fields.systemWorkItemType != 'Code Review Request' &&
      fields.systemWorkItemType != 'Code Review Response';
}
