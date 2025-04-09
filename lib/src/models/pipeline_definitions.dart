import 'dart:convert';

import 'package:http/http.dart';

class PipelineDefinitionsResponse {
  PipelineDefinitionsResponse({required this.definitions});

  factory PipelineDefinitionsResponse.fromJson(Map<String, dynamic> source) => PipelineDefinitionsResponse(
        definitions: (source['value'] as List<dynamic>? ?? [])
            .map((d) => Definition.fromJson(d as Map<String, dynamic>))
            .toList(),
      );

  static List<Definition> fromResponse(Response res) =>
      PipelineDefinitionsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).definitions;

  final List<Definition> definitions;
}

class Definition {
  Definition({
    required this.id,
    required this.name,
    required this.revision,
  });

  factory Definition.fromJson(Map<String, dynamic> json) => Definition(
        id: json['id'] as int?,
        name: json['name'] as String?,
        revision: json['revision'] as int?,
      );

  final int? id;
  final String? name;
  final int? revision;

  @override
  String toString() {
    return '_Definition(id: $id, name: $name, revision: $revision)';
  }
}
