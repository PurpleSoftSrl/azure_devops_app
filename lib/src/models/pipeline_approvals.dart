import 'dart:convert';

import 'package:http/http.dart';

class GetPipelineApprovalsResponse {
  GetPipelineApprovalsResponse({required this.approvals});

  factory GetPipelineApprovalsResponse.fromJson(Map<String, dynamic> json) => GetPipelineApprovalsResponse(
    approvals: List<Approval>.from(
      (json['value'] as List<dynamic>? ?? []).map((x) => Approval.fromJson(x as Map<String, dynamic>)),
    ),
  );

  static List<Approval> fromResponse(Response res) =>
      GetPipelineApprovalsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).approvals;

  final List<Approval> approvals;
}

class Approval {
  Approval({
    required this.id,
    required this.status,
    required this.instructions,
    required this.executionOrder,
    required this.minRequiredApprovers,
    required this.pipeline,
    required this.steps,
    required this.blockedApprovers,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
    id: json['id'] as String? ?? '',
    status: json['status'] as String? ?? '',
    instructions: json['instructions'] as String? ?? '',
    executionOrder: json['executionOrder'] as String? ?? '',
    minRequiredApprovers: json['minRequiredApprovers'] as int? ?? 0,
    pipeline: ApprovalPipeline.fromJson(json['pipeline'] as Map<String, dynamic>? ?? {}),
    steps: List<ApprovalStep>.from(
      (json['steps'] as List<dynamic>? ?? []).map((x) => ApprovalStep.fromJson(x as Map<String, dynamic>)),
    ),
    blockedApprovers: (json['blockedApprovers'] as List<dynamic>? ?? [])
        .map((x) => AssignedApprover.fromJson(x as Map<String, dynamic>))
        .toList(),
  );

  final String id;
  final String status;
  final String instructions;
  final String executionOrder;
  final int minRequiredApprovers;
  final ApprovalPipeline pipeline;
  final List<ApprovalStep> steps;
  final List<AssignedApprover> blockedApprovers;
}

class ApprovalPipeline {
  ApprovalPipeline({required this.owner, required this.id, required this.name});

  factory ApprovalPipeline.fromJson(Map<String, dynamic> json) => ApprovalPipeline(
    owner: Owner.fromJson(json['owner'] as Map<String, dynamic>? ?? {}),
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );

  final Owner owner;
  final String id;
  final String name;
}

class Owner {
  Owner({required this.id, required this.name});

  factory Owner.fromJson(Map<String, dynamic> json) =>
      Owner(id: json['id'] as int? ?? 0, name: json['name'] as String? ?? '');

  final int id;
  final String name;
}

class ApprovalStep {
  ApprovalStep({
    required this.assignedApprover,
    this.actualApprover,
    required this.status,
    this.deferredTo,
    this.lastModifiedOn,
    required this.order,
    this.initiatedOn,
  });

  factory ApprovalStep.fromJson(Map<String, dynamic> json) => ApprovalStep(
    assignedApprover: AssignedApprover.fromJson(json['assignedApprover'] as Map<String, dynamic>? ?? {}),
    actualApprover: json['actualApprover'] == null
        ? null
        : AssignedApprover.fromJson(json['actualApprover'] as Map<String, dynamic>? ?? {}),
    status: json['status'] as String? ?? '',
    deferredTo: json['deferredTo'] == null ? null : DateTime.parse(json['deferredTo'] as String).toLocal(),
    lastModifiedOn: DateTime.tryParse(json['lastModifiedOn'] as String? ?? '')?.toLocal(),
    order: json['order'] as int? ?? 0,
    initiatedOn: DateTime.tryParse(json['initiatedOn'] as String? ?? '')?.toLocal(),
  );

  final AssignedApprover assignedApprover;
  final AssignedApprover? actualApprover;
  final String status;
  final DateTime? deferredTo;
  final DateTime? lastModifiedOn;
  final int order;
  final DateTime? initiatedOn;
}

class AssignedApprover {
  AssignedApprover({required this.displayName, required this.id, required this.uniqueName, required this.descriptor});

  factory AssignedApprover.fromJson(Map<String, dynamic> json) => AssignedApprover(
    displayName: json['displayName'] as String? ?? '',
    id: json['id'] as String? ?? '',
    uniqueName: json['uniqueName'] as String? ?? '',
    descriptor: json['descriptor'] as String? ?? '',
  );

  final String displayName;
  final String id;
  final String uniqueName;
  final String descriptor;
}
