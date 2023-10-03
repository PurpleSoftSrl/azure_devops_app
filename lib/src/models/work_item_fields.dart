// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart';

class WorkItemTypeFieldsResponse {
  WorkItemTypeFieldsResponse({
    required this.fields,
  });

  factory WorkItemTypeFieldsResponse.fromJson(Map<String, dynamic> json) => WorkItemTypeFieldsResponse(
        fields: List<WorkItemField>.from(
          (json['value'] as List<dynamic>).map((f) => WorkItemField.fromJson(f as Map<String, dynamic>)),
        ),
      );

  static List<WorkItemField> fromResponse(Response res) =>
      WorkItemTypeFieldsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).fields;

  final List<WorkItemField> fields;
}

class WorkItemField {
  WorkItemField({
    required this.referenceName,
    required this.name,
    required this.required,
    this.defaultValue,
    this.allowedValues = const [],
    this.type,
  });

  factory WorkItemField.fromJson(Map<String, dynamic> json) => WorkItemField(
        referenceName: json['referenceName'] as String,
        name: json['name'] as String,
        required: json['alwaysRequired'] as bool? ?? false,
        defaultValue: json['defaultValue'] as String?,
        allowedValues: (json['allowedValues'] as List<dynamic>?)?.map((v) => v.toString()).toList() ?? [],
        type: json['type'] as String?,
      );

  final String referenceName;
  final String name;
  final bool required;
  final String? defaultValue;
  String? type;
  final List<String> allowedValues;

  @override
  String toString() {
    return 'WorkItemField(referenceName: $referenceName, name: $name, required: $required, defaultValue: $defaultValue)';
  }

  String toStringShort() {
    return 'WorkItemField(name: $name, required: $required, defaultValue: $defaultValue)';
  }
}
