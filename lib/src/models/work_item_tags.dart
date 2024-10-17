import 'dart:convert';

import 'package:http/http.dart';

class WorkItemTagsResponse {
  WorkItemTagsResponse({
    required this.tags,
  });

  factory WorkItemTagsResponse.fromResponse(Response res) =>
      WorkItemTagsResponse.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory WorkItemTagsResponse.fromJson(Map<String, dynamic> json) => WorkItemTagsResponse(
        tags: List<WorkItemTag>.from(
          (json['value'] as List<dynamic>).map((x) => WorkItemTag.fromJson(x as Map<String, dynamic>)),
        ),
      );

  final List<WorkItemTag> tags;
}

class WorkItemTag {
  WorkItemTag({required this.name});

  factory WorkItemTag.fromResponse(Response res) => WorkItemTag.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory WorkItemTag.fromJson(Map<String, dynamic> json) => WorkItemTag(name: json['name'] as String);

  final String name;
}
