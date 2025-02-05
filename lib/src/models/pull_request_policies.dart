import 'dart:convert';

import 'package:http/http.dart';

class PoliciesResponse {
  PoliciesResponse({required this.policies});

  factory PoliciesResponse.fromResponse(Response res) =>
      PoliciesResponse.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory PoliciesResponse.fromJson(Map<String, dynamic> json) => PoliciesResponse(
        policies: (json['value'] as List<dynamic>).map((p) => Policy.fromJson(p as Map<String, dynamic>)).toList(),
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
    this.configuration,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
        artifactId: json['artifactId'] as String?,
        evaluationId: json['evaluationId'] as String?,
        startedDate: json['startedDate'] == null ? null : DateTime.parse(json['startedDate']!.toString()).toLocal(),
        status: json['status'] as String?,
        completedDate:
            json['completedDate'] == null ? null : DateTime.parse(json['completedDate']!.toString()).toLocal(),
        configuration: json['configuration'] == null
            ? null
            : _PolicyConfiguration.fromJson(json['configuration'] as Map<String, dynamic>),
      );

  final String? artifactId;
  final String? evaluationId;
  final DateTime? startedDate;
  final String? status;
  final DateTime? completedDate;
  final _PolicyConfiguration? configuration;

  @override
  String toString() {
    return 'Policy(artifactId: $artifactId, evaluationId: $evaluationId, startedDate: $startedDate, status: $status, completedDate: $completedDate, configuration: $configuration)';
  }
}

class _PolicyConfiguration {
  _PolicyConfiguration({
    required this.isEnabled,
    required this.isBlocking,
    required this.isDeleted,
    required this.settings,
    required this.type,
  });

  factory _PolicyConfiguration.fromJson(Map<String, dynamic> json) => _PolicyConfiguration(
        isEnabled: json['isEnabled'] as bool? ?? false,
        isBlocking: json['isBlocking'] as bool? ?? false,
        isDeleted: json['isDeleted'] as bool? ?? false,
        settings: json['settings'] == null ? null : _PolicySettings.fromJson(json['settings'] as Map<String, dynamic>),
        type: json['type'] == null ? null : _PolicyType.fromJson(json['type'] as Map<String, dynamic>),
      );

  final bool isEnabled;
  final bool isBlocking;
  final bool isDeleted;
  final _PolicySettings? settings;
  final _PolicyType? type;
}

class _PolicySettings {
  _PolicySettings({
    required this.allowNoFastForward,
    required this.allowSquash,
    required this.allowRebase,
    required this.allowRebaseMerge,
  });

  factory _PolicySettings.fromJson(Map<String, dynamic> json) => _PolicySettings(
        allowNoFastForward: json['allowNoFastForward'] as bool? ?? false,
        allowSquash: json['allowSquash'] as bool? ?? false,
        allowRebase: json['allowRebase'] as bool? ?? false,
        allowRebaseMerge: json['allowRebaseMerge'] as bool? ?? false,
      );

  final bool allowNoFastForward;
  final bool allowSquash;
  final bool allowRebase;
  final bool allowRebaseMerge;
}

class _PolicyType {
  _PolicyType({
    required this.id,
    required this.displayName,
  });

  factory _PolicyType.fromJson(Map<String, dynamic> json) => _PolicyType(
        id: json['id'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
      );

  final String? id;
  final String? displayName;
}
