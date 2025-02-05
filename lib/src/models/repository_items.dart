import 'dart:convert';

import 'package:http/http.dart';

class GetRepoItemsResponse {
  GetRepoItemsResponse({
    required this.count,
    required this.repoItems,
  });

  factory GetRepoItemsResponse.fromJson(Map<String, dynamic> json) => GetRepoItemsResponse(
        count: json['count'] as int,
        repoItems: List<RepoItem>.from(
          (json['value'] as List<dynamic>).map((i) => RepoItem.fromJson(i as Map<String, dynamic>)),
        ),
      );

  static List<RepoItem> fromResponse(Response res) =>
      GetRepoItemsResponse.fromJson(json.decode(res.body) as Map<String, dynamic>).repoItems;

  final int count;
  final List<RepoItem> repoItems;
}

class RepoItem {
  RepoItem({
    required this.objectId,
    required this.commitId,
    required this.path,
    this.isFolder = false,
    this.contentMetadata,
    required this.url,
  });

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

  final String objectId;
  final String commitId;
  final String path;
  final bool isFolder;
  final _ContentMetadata? contentMetadata;
  final String url;
}

class _ContentMetadata {
  _ContentMetadata({required this.fileName});

  factory _ContentMetadata.fromJson(Map<String, dynamic> json) => _ContentMetadata(
        fileName: json['fileName'] as String,
      );

  final String fileName;
}
