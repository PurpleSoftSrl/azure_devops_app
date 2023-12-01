import 'dart:convert';

import 'package:azure_devops/src/services/azure_api_service.dart';
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

class WorkItemFieldsWithRules {
  WorkItemFieldsWithRules({required this.fields, required this.rules, required this.transitions});

  final LabeledWorkItemFields fields;
  final WorkItemTypeRules rules;
  final Map<String, List<String>> transitions;
}

class WorkItemField {
  WorkItemField({
    required this.referenceName,
    required this.name,
    this.required = false,
    this.readOnly = false,
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
  bool required;
  bool readOnly;
  final String? defaultValue;
  String? type;
  final List<String> allowedValues;

  @override
  String toString() {
    return 'WorkItemField(referenceName: $referenceName, name: $name, required: $required, defaultValue: $defaultValue)';
  }
}
