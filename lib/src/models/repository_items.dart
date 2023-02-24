import 'dart:convert';

class GetRepoItemsResponse {
  factory GetRepoItemsResponse.fromRawJson(String str) =>
      GetRepoItemsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  factory GetRepoItemsResponse.fromJson(Map<String, dynamic> json) => GetRepoItemsResponse(
        count: json['count'] as int,
        repoItems: List<RepoItem>.from(
          (json['value'] as List<dynamic>).map((i) => RepoItem.fromJson(i as Map<String, dynamic>)),
        ),
      );

  GetRepoItemsResponse({
    required this.count,
    required this.repoItems,
  });

  final int count;
  final List<RepoItem> repoItems;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'count': count,
        'value': List<dynamic>.from(repoItems.map((x) => x.toJson())),
      };
}

class RepoItem {
  factory RepoItem.fromRawJson(String str) => RepoItem.fromJson(json.decode(str) as Map<String, dynamic>);

  factory RepoItem.fromJson(Map<String, dynamic> json) => RepoItem(
        objectId: json['objectId'] as String,
        gitObjectType: gitObjectTypeValues.map[json['gitObjectType']]!,
        commitId: json['commitId'] as String,
        path: json['path'] as String,
        isFolder: json['isFolder'] as bool? ?? false,
        contentMetadata: json['contentMetadata'] == null
            ? null
            : ContentMetadata.fromJson(json['contentMetadata'] as Map<String, dynamic>),
        url: json['url'] as String,
      );

  RepoItem({
    required this.objectId,
    required this.gitObjectType,
    required this.commitId,
    required this.path,
    this.isFolder = false,
    this.contentMetadata,
    required this.url,
  });

  final String objectId;
  final GitObjectType gitObjectType;
  final String commitId;
  final String path;
  final bool isFolder;
  final ContentMetadata? contentMetadata;
  final String url;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'objectId': objectId,
        'gitObjectType': gitObjectTypeValues.reverse[gitObjectType],
        'commitId': commitId,
        'path': path,
        'isFolder': isFolder,
        'contentMetadata': contentMetadata?.toJson(),
        'url': url,
      };
}

class ContentMetadata {
  factory ContentMetadata.fromRawJson(String str) => ContentMetadata.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ContentMetadata.fromJson(Map<String, dynamic> json) => ContentMetadata(
        fileName: json['fileName'] as String,
      );
  ContentMetadata({
    required this.fileName,
  });

  final String fileName;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
      };
}

enum GitObjectType { tree, blob }

final gitObjectTypeValues = EnumValues({'blob': GitObjectType.blob, 'tree': GitObjectType.tree});

class EnumValues<T> {
  EnumValues(this.map);
  Map<String, T> map;
  late Map<T, String> reverseMap;

  Map<T, String> get reverse {
    return reverseMap = map.map((k, v) => MapEntry(v, k));
  }
}
