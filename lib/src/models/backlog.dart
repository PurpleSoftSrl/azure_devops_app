import 'dart:convert';

import 'package:http/src/response.dart';

class BacklogsResponse {
  BacklogsResponse({required this.boards});

  factory BacklogsResponse.fromJson(Map<String, dynamic> json) => BacklogsResponse(
        boards: List<Backlog>.from(
          (json['value'] as List<dynamic>? ?? []).map((x) => Backlog.fromJson(x as Map<String, dynamic>)),
        ),
      );

  final List<Backlog> boards;

  static List<Backlog> fromResponse(Response res) =>
      BacklogsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).boards;
}

class Backlog {
  Backlog({
    required this.id,
    required this.name,
  });

  factory Backlog.fromJson(Map<String, dynamic> json) => Backlog(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  final String id;
  final String name;
}
