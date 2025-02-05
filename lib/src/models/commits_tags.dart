import 'dart:convert';

import 'package:http/http.dart';

class TagsResponse {
  TagsResponse({required this.data});

  factory TagsResponse.fromJson(Map<String, dynamic> json) => TagsResponse(
        data: _TagsDataProvider.fromJson(json['dataProviders'] as Map<String, dynamic>),
      );

  static TagsData? fromResponse(Response res) =>
      TagsResponse.fromJson(json.decode(res.body) as Map<String, dynamic>).data.tagsData;

  final _TagsDataProvider data;
}

class _TagsDataProvider {
  _TagsDataProvider({required this.tagsData});

  factory _TagsDataProvider.fromJson(Map<String, dynamic> json) => _TagsDataProvider(
        tagsData: TagsData.fromJson(
          json['ms.vss-code-web.commits-data-provider'] as Map<String, dynamic>,
        ),
      );

  final TagsData tagsData;
}

class TagsData {
  TagsData({required this.tags});

  factory TagsData.fromJson(Map<String, dynamic> json) => TagsData(
        tags: Map<String, List<dynamic>>.from(json['tags'] as Map<String, dynamic>).map(
          (k, v) => MapEntry<String, List<Tag>>(
            k,
            List<Tag>.from(v.map((a) => Tag.fromJson(a as Map<String, dynamic>))),
          ),
        ),
      );

  final Map<String, List<Tag>> tags;
  late String projectId;
  late String repositoryId;
}

class Tag {
  Tag({
    required this.name,
    required this.comment,
    required this.tagger,
    required this.resolvedCommitId,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        name: json['name'] as String,
        comment: json['comment'] as String?,
        tagger: json['tagger'] == null ? null : _Tagger.fromJson(json['tagger'] as Map<String, dynamic>),
        resolvedCommitId: json['resolvedCommitId'] as String,
      );

  final String name;
  final String? comment;
  final _Tagger? tagger;
  final String resolvedCommitId;
}

class _Tagger {
  _Tagger({
    required this.name,
    required this.email,
    required this.date,
  });

  factory _Tagger.fromJson(Map<String, dynamic> json) => _Tagger(
        name: json['name'] as String?,
        email: json['email'] as String?,
        date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
      );

  final String? name;
  final String? email;
  final DateTime? date;
}
