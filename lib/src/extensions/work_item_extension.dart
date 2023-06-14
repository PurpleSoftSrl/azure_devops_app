import 'package:azure_devops/src/models/work_items.dart';

extension WorkItemExt on WorkItem {
  bool get canBeChanged =>
      fields.systemWorkItemType != 'Feedback Request' &&
      fields.systemWorkItemType != 'Feedback Response' &&
      fields.systemWorkItemType != 'Code Review Request' &&
      fields.systemWorkItemType != 'Code Review Response';

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
