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
        if (buildStatus != null) 'buildStatus': buildStatus,
        if (definitionName != null) 'definitionName': definitionName,
        'projectId': projectId,
        if (branch != null) 'branch': branch,
        if (mergeResult != null) 'mergeResult': mergeResult,
        if (pullrequestCreatedBy != null) 'pullrequestCreatedBy': pullrequestCreatedBy,
        if (repository != null) 'repository': repository,
        if (pipelineId != null) 'pipelineId': pipelineId,
      };
}

enum EventType {
  buildCompleted('build.complete', EventCategory.pipelines),
  pullRequestCreated('git.pullrequest.created', EventCategory.pullRequests),
  pullRequestUpdated('git.pullrequest.updated', EventCategory.pullRequests),
  pullRequestCommented('ms.vss-code.git-pullrequest-comment-event', EventCategory.pullRequests),
  workItemCreated('workitem.created', EventCategory.workItems),
  workItemUpdated('workitem.updated', EventCategory.workItems),
  approvalPending('ms.vss-pipelinechecks-events.approval-pending', EventCategory.pipelines),
  unknown('', EventCategory.unknown);

  const EventType(this.value, this.category);

  final String value;
  final EventCategory category;

  static EventType fromString(String value) {
    return switch (value) {
      'build.complete' => EventType.buildCompleted,
      'git.pullrequest.created' => EventType.pullRequestCreated,
      'git.pullrequest.updated' => EventType.pullRequestUpdated,
      'ms.vss-code.git-pullrequest-comment-event' => EventType.pullRequestCommented,
      'workitem.created' => EventType.workItemCreated,
      'workitem.updated' => EventType.workItemUpdated,
      'ms.vss-pipelinechecks-events.approval-pending' => EventType.approvalPending,
      _ => EventType.unknown,
    };
  }

  String get description {
    return switch (this) {
      EventType.buildCompleted => 'Build completed',
      EventType.pullRequestCreated => 'Pull request created',
      EventType.pullRequestUpdated => 'Pull request updated',
      EventType.pullRequestCommented => 'Pull request commented',
      EventType.workItemCreated => 'Work item created',
      EventType.workItemUpdated => 'Work item updated',
      EventType.approvalPending => 'Approval pending',
      _ => '',
    };
  }

  String get publisherId {
    return switch (this) {
      EventType.buildCompleted ||
      EventType.pullRequestUpdated ||
      EventType.pullRequestCreated ||
      EventType.pullRequestCommented ||
      EventType.workItemCreated ||
      EventType.workItemUpdated =>
        'tfs',
      EventType.approvalPending => 'pipelines',
      _ => '',
    };
  }
}

enum EventCategory {
  pipelines,
  workItems,
  pullRequests,
  unknown;

  List<EventType> get eventTypes {
    return switch (this) {
      EventCategory.pipelines => [
          EventType.approvalPending,
          EventType.buildCompleted,
        ],
      EventCategory.workItems => [
          EventType.workItemCreated,
          EventType.workItemUpdated,
        ],
      EventCategory.pullRequests => [
          EventType.pullRequestCreated,
          EventType.pullRequestUpdated,
          EventType.pullRequestCommented,
        ],
      _ => [],
    };
  }

  String get description {
    return switch (this) {
      EventCategory.pipelines => 'Pipelines',
      EventCategory.workItems => 'Work items',
      EventCategory.pullRequests => 'Pull requests',
      _ => '',
    };
  }
}
