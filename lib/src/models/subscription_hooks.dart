import 'dart:convert';

import 'package:http/http.dart';

class GetHookSubscriptionsResponse {
  GetHookSubscriptionsResponse({required this.subscriptions});

  factory GetHookSubscriptionsResponse.fromJson(Map<String, dynamic> json) => GetHookSubscriptionsResponse(
        subscriptions: List<HookSubscription>.from(
          (json['value'] as List<dynamic>? ?? [])
              .map((x) => HookSubscription.fromJson(x as Map<String, dynamic>))
              .toList(),
        ),
      );

  static List<HookSubscription> fromResponse(Response res) =>
      GetHookSubscriptionsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).subscriptions;

  final List<HookSubscription> subscriptions;
}

class HookSubscription {
  HookSubscription({
    required this.id,
    required this.status,
    required this.publisherId,
    required this.eventType,
    required this.resourceVersion,
    required this.eventDescription,
    required this.consumerId,
    required this.consumerActionId,
    required this.actionDescription,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.publisherInputs,
    required this.consumerInputs,
  });

  factory HookSubscription.fromJson(Map<String, dynamic> json) => HookSubscription(
        id: json['id'] as String? ?? '',
        status: json['status'] as String? ?? '',
        publisherId: json['publisherId'] as String? ?? '',
        eventType: EventType.fromString(json['eventType'] as String? ?? ''),
        resourceVersion: json['resourceVersion'] as String? ?? '',
        eventDescription: json['eventDescription'] as String? ?? '',
        consumerId: json['consumerId'] as String? ?? '',
        consumerActionId: json['consumerActionId'] as String? ?? '',
        actionDescription: json['actionDescription'] as String? ?? '',
        createdBy: EdBy.fromJson(json['createdBy'] as Map<String, dynamic>),
        createdDate: DateTime.parse(json['createdDate'].toString()).toLocal(),
        modifiedBy: EdBy.fromJson(json['modifiedBy'] as Map<String, dynamic>),
        modifiedDate: DateTime.parse(json['modifiedDate'].toString()).toLocal(),
        publisherInputs: PublisherInputs.fromJson(json['publisherInputs'] as Map<String, dynamic>? ?? {}),
        consumerInputs: ConsumerInputs.fromJson(json['consumerInputs'] as Map<String, dynamic>? ?? {}),
      );

  final String id;
  final String status;
  final String publisherId;
  final EventType eventType;
  final String? resourceVersion;
  final String eventDescription;
  final String consumerId;
  final String consumerActionId;
  final String actionDescription;
  final EdBy createdBy;
  final DateTime createdDate;
  final EdBy modifiedBy;
  final DateTime modifiedDate;
  final PublisherInputs publisherInputs;
  final ConsumerInputs consumerInputs;
}

class ConsumerInputs {
  ConsumerInputs({required this.url});

  factory ConsumerInputs.fromJson(Map<String, dynamic> json) => ConsumerInputs(url: json['url'] as String? ?? '');

  final String url;
}

class EdBy {
  EdBy({
    required this.displayName,
    required this.id,
    required this.uniqueName,
    required this.descriptor,
  });

  factory EdBy.fromJson(Map<String, dynamic> json) => EdBy(
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

class PublisherInputs {
  PublisherInputs({
    this.buildStatus,
    this.definitionName,
    required this.projectId,
    this.branch,
    this.mergeResult,
    this.pullrequestCreatedBy,
    this.repository,
    this.pipelineId,
  });

  factory PublisherInputs.fromJson(Map<String, dynamic> json) => PublisherInputs(
        buildStatus: json['buildStatus'] as String? ?? '',
        definitionName: json['definitionName'] as String? ?? '',
        projectId: json['projectId'] as String? ?? '',
        branch: json['branch'] as String? ?? '',
        mergeResult: json['mergeResult'] as String? ?? '',
        pullrequestCreatedBy: json['pullrequestCreatedBy'] as String? ?? '',
        repository: json['repository'] as String? ?? '',
        pipelineId: json['pipelineId'] as String? ?? '',
      );

  final String? buildStatus;
  final String? definitionName;
  final String projectId;
  final String? branch;
  final String? mergeResult;
  final String? pullrequestCreatedBy;
  final String? repository;
  final String? pipelineId;

  Map<String, dynamic> toJson() => {
        'buildStatus': buildStatus,
        'definitionName': definitionName,
        'projectId': projectId,
        'branch': branch,
        'mergeResult': mergeResult,
        'pullrequestCreatedBy': pullrequestCreatedBy,
        'repository': repository,
        'pipelineId': pipelineId,
      };
}

enum EventType {
  buildCompleted('build.complete'),
  pullRequestUpdated('git.pullrequest.merged'),
  pullRequestMerged('git.pullrequest.updated'),
  workItemUpdated('workitem.updated'),
  approvalPending('ms.vss-pipelinechecks-events.approval-pending'),
  approvalCompleted('ms.vss-pipelinechecks-events.approval-completed'),
  unknown('');

  const EventType(this.value);

  final String value;

  static EventType fromString(String value) {
    return switch (value) {
      'build.complete' => EventType.buildCompleted,
      'git.pullrequest.merged' => EventType.pullRequestMerged,
      'git.pullrequest.updated' => EventType.pullRequestUpdated,
      'workitem.updated' => EventType.workItemUpdated,
      'ms.vss-pipelinechecks-events.approval-pending' => EventType.approvalPending,
      'ms.vss-pipelinechecks-events.approval-completed' => EventType.approvalCompleted,
      _ => EventType.unknown,
    };
  }

  String get description {
    return switch (this) {
      EventType.buildCompleted => 'Build completed',
      EventType.pullRequestUpdated => 'Pull request updated',
      EventType.pullRequestMerged => 'Pull request merged',
      EventType.workItemUpdated => 'Work item updated',
      EventType.approvalPending => 'Approval pending',
      EventType.approvalCompleted => 'Approval completed',
      _ => '',
    };
  }

  String get publisherId {
    return switch (this) {
      EventType.buildCompleted ||
      EventType.pullRequestUpdated ||
      EventType.pullRequestMerged ||
      EventType.workItemUpdated =>
        'tfs',
      EventType.approvalPending || EventType.approvalCompleted => 'pipelines',
      _ => '',
    };
  }
}
