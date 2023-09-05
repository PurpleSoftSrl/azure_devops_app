import 'dart:convert';

import 'package:http/http.dart';

class PoliciesResponse {
  PoliciesResponse({required this.policies});

  factory PoliciesResponse.fromResponse(Response res) =>
      PoliciesResponse.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory PoliciesResponse.fromJson(Map<String, dynamic> json) => PoliciesResponse(
        policies:
            List<Policy>.from((json['value'] as List<dynamic>).map((p) => Policy.fromJson(p as Map<String, dynamic>))),
      );

  final List<Policy> policies;
}

class Policy {
  Policy({
    this.artifactId,
    this.evaluationId,
    this.startedDate,
    this.status,
    this.completedDate,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
        artifactId: json['artifactId'] as String?,
        evaluationId: json['evaluationId'] as String?,
        startedDate: json['startedDate'] == null ? null : DateTime.parse(json['startedDate']!.toString()).toLocal(),
        status: json['status'] as String?,
        completedDate:
            json['completedDate'] == null ? null : DateTime.parse(json['completedDate']!.toString()).toLocal(),
      );

  final String? artifactId;
  final String? evaluationId;
  final DateTime? startedDate;
  final String? status;
  final DateTime? completedDate;
}
