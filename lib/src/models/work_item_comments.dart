import 'dart:convert';

import 'package:http/http.dart';

class WorkItemCommentRes {
  WorkItemCommentRes({
    required this.totalCount,
    required this.count,
    required this.comments,
  });

  factory WorkItemCommentRes.fromResponse(Response res) =>
      WorkItemCommentRes.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory WorkItemCommentRes.fromJson(Map<String, dynamic> json) => WorkItemCommentRes(
        totalCount: json['totalCount'] as int,
        count: json['count'] as int,
        comments: List<Comment>.from(
          (json['comments'] as List<dynamic>).map(
            (c) => Comment.fromJson(c as Map<String, dynamic>),
          ),
        ),
      );

  final int totalCount;
  final int count;
  final List<Comment> comments;
}

class Comment {
  Comment({
    required this.workItemId,
    required this.id,
    required this.version,
    required this.text,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.format,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        workItemId: json['workItemId'] as int,
        id: json['id'] as int,
        version: json['version'] as int,
        text: json['text'] as String,
        createdBy: EdBy.fromJson(json['createdBy'] as Map<String, dynamic>),
        createdDate: DateTime.parse(json['createdDate']!.toString()).toLocal(),
        modifiedBy: EdBy.fromJson(json['modifiedBy'] as Map<String, dynamic>),
        modifiedDate: DateTime.parse(json['modifiedDate']!.toString()).toLocal(),
        format: json['format'] as String,
      );

  final int workItemId;
  final int id;
  final int version;
  final String text;
  final EdBy createdBy;
  final DateTime createdDate;
  final EdBy modifiedBy;
  final DateTime modifiedDate;
  final String format;
}

class EdBy {
  EdBy({
    required this.id,
    required this.uniqueName,
    required this.descriptor,
    required this.displayName,
  });

  factory EdBy.fromJson(Map<String, dynamic> json) => EdBy(
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        descriptor: json['descriptor'] as String,
        displayName: json['displayName'] as String,
      );

  final String id;
  final String uniqueName;
  final String descriptor;
  final String displayName;
}
