import 'package:azure_devops/src/models/work_item_updates.dart';

extension WorkItemUpdateExt on WorkItemUpdate {
  bool get hasSUpportedChanges {
    return fields.systemState?.newValue != null ||
        fields.systemWorkItemType?.newValue != null ||
        fields.systemAssignedTo?.newValue?.displayName != null ||
        fields.microsoftVstsSchedulingEffort != null ||
        fields.systemTitle != null ||
        fields.systemHistory != null;
  }
}
