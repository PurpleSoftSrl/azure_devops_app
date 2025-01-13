import 'package:azure_devops/src/models/work_item_link_types.dart';
import 'package:azure_devops/src/models/work_item_updates.dart';
import 'package:azure_devops/src/models/work_items.dart';

extension WorkItemRelationExt on Relation {
  String toReadableString() {
    final id = url?.split('/').lastOrNull ?? '';
    final attributes = this.attributes;
    final attributesStr = attributes != null ? attributes.name : '';
    return '$id - $attributesStr';
  }

  String get linkedWorkItemProjectId => url?.substring(0, url?.indexOf('/_apis/')).split('/').lastOrNull ?? '';

  int get linkedWorkItemId => int.tryParse(url?.split('/').lastOrNull ?? '') ?? 0;

  WorkItemLink toWorkItemLink({required int index}) => WorkItemLink(
        linkTypeReferenceName: rel ?? '',
        linkTypeName: attributes?.name ?? '',
        linkedWorkItemId: int.tryParse(url?.split('/').lastOrNull ?? '') ?? 0,
        comment: attributes?.comment ?? '',
        index: index,
      );

  bool get isWorkItemLink => rel?.startsWith('System.LinkTypes.') ?? false;
}

extension WorkItemExt on WorkItem {
  List<Relation> get workItemLinks => links.where((l) => l.isWorkItemLink).toList();
}
