import 'dart:convert';

import 'package:http/http.dart';

class CommitChanges {
  factory CommitChanges.fromResponse(Response res) =>
      CommitChanges.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  factory CommitChanges.fromJson(Map<String, dynamic> json) => CommitChanges(
        changeCounts: ChangeCounts.fromJson(json['changeCounts'] as Map<String, dynamic>),
        changes: json['changes'] == null
            ? []
            : List<Change?>.from(
                (json['changes'] as List<dynamic>).map((e) => Change.fromJson(e as Map<String, dynamic>)),
              ),
      );

  CommitChanges({
    required this.changeCounts,
    required this.changes,
  });

  final ChangeCounts? changeCounts;
  final List<Change?>? changes;

  @override
  String toString() => 'CommitDetail(changeCounts: $changeCounts, changes: $changes)';
}

class ChangeCounts {
  factory ChangeCounts.fromJson(Map<String, dynamic> json) => ChangeCounts(
        edit: json['Edit'] as int?,
        add: json['Add'] as int?,
        delete: json['Delete'] as int?,
      );
  ChangeCounts({
    required this.edit,
    required this.add,
    required this.delete,
  });

  final int? edit;
  final int? add;
  final int? delete;

  @override
  String toString() => 'ChangeCounts(edit: $edit: add: $add, delete: $delete)';
}

class Change {
  factory Change.fromJson(Map<String, dynamic> json) => Change(
        item: Item.fromJson(json['item'] as Map<String, dynamic>),
        changeType: json['changeType'] as String?,
      );
  Change({
    required this.item,
    required this.changeType,
  });

  final Item? item;
  final String? changeType;

  @override
  String toString() => 'Change(item: $item, changeType: $changeType)';
}

class Item {
  factory Item.fromJson(Map<String, dynamic> json) => Item(
        objectId: json['objectId'] as String?,
        originalObjectId: json['originalObjectId'] as String?,
        gitObjectType: json['gitObjectType'] as String?,
        commitId: json['commitId'] as String?,
        path: json['path'] as String?,
        url: json['url'] as String?,
      );
  Item({
    required this.objectId,
    required this.originalObjectId,
    required this.gitObjectType,
    required this.commitId,
    required this.path,
    required this.url,
  });

  final String? objectId;
  final String? originalObjectId;
  final String? gitObjectType;
  final String? commitId;
  final String? path;
  final String? url;

  @override
  String toString() {
    return 'Item(objectId: $objectId, originalObjectId: $originalObjectId, gitObjectType: $gitObjectType, commitId: $commitId, path: $path, url: $url)';
  }
}
