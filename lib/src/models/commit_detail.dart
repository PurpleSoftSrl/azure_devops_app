class CommitChanges {
  factory CommitChanges.fromJson(Map<String, dynamic> json) => CommitChanges(
        changeCounts: _ChangeCounts.fromJson(json['changeCounts'] as Map<String, dynamic>),
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

  final _ChangeCounts? changeCounts;
  final List<Change?>? changes;

  @override
  String toString() => 'CommitDetail(changeCounts: $changeCounts, changes: $changes)';
}

class _ChangeCounts {
  factory _ChangeCounts.fromJson(Map<String, dynamic> json) => _ChangeCounts(
        edit: json['Edit'] as int?,
        add: json['Add'] as int?,
        delete: json['Delete'] as int?,
      );
  _ChangeCounts({
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
        item: _Item.fromJson(json['item'] as Map<String, dynamic>),
        changeType: json['changeType'] as String?,
      );
  Change({
    required this.item,
    required this.changeType,
  });

  final _Item? item;
  final String? changeType;

  @override
  String toString() => 'Change(item: $item, changeType: $changeType)';
}

class _Item {
  factory _Item.fromJson(Map<String, dynamic> json) => _Item(
        objectId: json['objectId'] as String?,
        originalObjectId: json['originalObjectId'] as String?,
        gitObjectType: json['gitObjectType'] as String?,
        commitId: json['commitId'] as String?,
        path: json['path'] as String?,
        url: json['url'] as String?,
      );
  _Item({
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
