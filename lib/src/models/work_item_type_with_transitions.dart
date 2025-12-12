import 'dart:convert';

import 'package:http/http.dart';

class WorkItemTypeWithTransitions {
  WorkItemTypeWithTransitions({required this.xmlForm, required this.referenceName, required this.transitions});

  factory WorkItemTypeWithTransitions.fromResponse(Response res) =>
      WorkItemTypeWithTransitions.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  factory WorkItemTypeWithTransitions.fromJson(Map<String, dynamic> json) => WorkItemTypeWithTransitions(
    xmlForm: json['xmlForm'] as String? ?? '',
    referenceName: json['referenceName'] as String? ?? '',
    transitions: (json['transitions'] as Map<String, dynamic>).map(
      (from, tos) => MapEntry(from, (tos as List<dynamic>).map((e) => e['to'].toString()).toList()),
    ),
  );

  final String xmlForm;
  final String referenceName;
  final Map<String, List<String>> transitions;
}
