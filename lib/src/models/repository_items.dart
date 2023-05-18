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
}

class RepoItem {
  factory RepoItem.fromRawJson(String str) => RepoItem.fromJson(json.decode(str) as Map<String, dynamic>);

  factory RepoItem.fromJson(Map<String, dynamic> json) => RepoItem(
        objectId: json['objectId'] as String,
        commitId: json['commitId'] as String,
        path: json['path'] as String,
        isFolder: json['isFolder'] as bool? ?? false,
        contentMetadata: json['contentMetadata'] == null
            ? null
            : _ContentMetadata.fromJson(json['contentMetadata'] as Map<String, dynamic>),
        url: json['url'] as String,
      );

  RepoItem({
    required this.objectId,
    required this.commitId,
    required this.path,
    this.isFolder = false,
    this.contentMetadata,
    required this.url,
  });

  final String objectId;
  final String commitId;
  final String path;
  final bool isFolder;
  final _ContentMetadata? contentMetadata;
  final String url;
}

class _ContentMetadata {
  factory _ContentMetadata.fromJson(Map<String, dynamic> json) => _ContentMetadata(
        fileName: json['fileName'] as String,
      );

  _ContentMetadata({required this.fileName});

  final String fileName;
}
