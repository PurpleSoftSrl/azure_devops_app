import 'dart:convert';

import 'package:http/http.dart';

class SavedQueriesResponse {
  SavedQueriesResponse({required this.queries});

  factory SavedQueriesResponse.fromJson(Map<String, dynamic> json) => SavedQueriesResponse(
        queries: List<SavedQuery>.from(
          (json['value'] as List<dynamic>? ?? []).map((x) => SavedQuery.fromJson(x as Map<String, dynamic>)),
        ),
      );

  static List<SavedQuery> fromResponse(Response res) =>
      SavedQueriesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).queries;

  final List<SavedQuery> queries;
}

class SavedQuery {
  SavedQuery({
    required this.id,
    required this.name,
    required this.path,
    required this.wiql,
    required this.isFolder,
    required this.hasChildren,
    required this.children,
  });

  factory SavedQuery.fromJson(Map<String, dynamic> json) => SavedQuery(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        path: json['path'] as String? ?? '',
        wiql: json['wiql'] as String? ?? '',
        isFolder: json['isFolder'] as bool? ?? false,
        hasChildren: json['hasChildren'] as bool? ?? false,
        children: List<ChildQuery>.from(
          (json['children'] as List<dynamic>? ?? []).map((x) => ChildQuery.fromJson(x as Map<String, dynamic>)),
        ),
      );

  static SavedQuery fromResponse(Response res) => SavedQuery.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final String id;
  final String name;
  final String path;
  final String wiql;
  final bool isFolder;
  final bool hasChildren;
  final List<ChildQuery> children;
}

class ChildQuery {
  ChildQuery({
    required this.id,
    required this.name,
    required this.path,
    required this.queryType,
    required this.isPublic,
    required this.isFolder,
    required this.hasChildren,
    required this.url,
  });

  factory ChildQuery.fromJson(Map<String, dynamic> json) => ChildQuery(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        path: json['path'] as String? ?? '',
        queryType: json['queryType'] as String? ?? '',
        isPublic: json['isPublic'] as bool? ?? false,
        isFolder: json['isFolder'] as bool? ?? false,
        hasChildren: json['hasChildren'] as bool? ?? false,
        url: json['url'] as String? ?? '',
      );

  final String id;
  final String name;
  final String path;
  final String queryType;
  final bool isPublic;
  final bool isFolder;
  final bool hasChildren;
  final String url;
}
