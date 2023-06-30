import 'package:azure_devops/src/models/work_item_updates.dart';

extension WorkItemUpdateExt on WorkItemUpdate {
  bool get hasSupportedChanges {
    final fields = this.fields;

    if (fields == null) return false;

    return fields.systemState?.newValue != null ||
        fields.systemWorkItemType?.newValue != null ||
        fields.systemAssignedTo?.oldValue?.displayName != null ||
        fields.systemAssignedTo?.newValue?.displayName != null ||
        fields.microsoftVstsSchedulingEffort != null ||
        fields.systemTitle != null ||
        // show only attachments (not links)
        (relations != null && relations!.added != null && relations!.added!.any((r) => r.rel == 'AttachedFile')) ||
        (relations != null && relations!.removed != null && relations!.removed!.any((r) => r.rel == 'AttachedFile')) ||
        (relations != null && relations!.updated != null && relations!.updated!.any((r) => r.rel == 'AttachedFile'));
  }
}
