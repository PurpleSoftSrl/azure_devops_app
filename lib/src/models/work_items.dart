// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:azure_devops/src/models/work_item_updates.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class GetWorkItemIds {
  GetWorkItemIds({required this.workItems});

  factory GetWorkItemIds.fromJson(Map<String, dynamic> json) => GetWorkItemIds(
        workItems: List<_WorkItemId>.from(
          (json['workItems'] as List<dynamic>).map((w) => _WorkItemId.fromJson(w as Map<String, dynamic>)),
        ),
      );

  static List<_WorkItemId> fromResponse(Response res) =>
      GetWorkItemIds.fromJson(jsonDecode(res.body) as Map<String, dynamic>).workItems;

  final List<_WorkItemId> workItems;
}

class _WorkItemId {
  _WorkItemId({required this.id});

  factory _WorkItemId.fromJson(Map<String, dynamic> json) => _WorkItemId(id: json['id'] as int);

  final int id;
}

class GetWorkItemsResponse {
  GetWorkItemsResponse({
    required this.count,
    required this.items,
  });

  factory GetWorkItemsResponse.fromJson(Map<String, dynamic> json) => GetWorkItemsResponse(
        count: json['count'] as int,
        items: List<WorkItem>.from(
          (json['value'] as List<dynamic>).map((i) => WorkItem.fromJson(i as Map<String, dynamic>)),
        ),
      );

  static List<WorkItem> fromResponse(Response res) =>
      GetWorkItemsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).items;

  final int count;
  final List<WorkItem> items;
}

class WorkItemWithUpdates {
  WorkItemWithUpdates({
    required this.item,
    required this.updates,
  });

  final WorkItem item;
  final List<WorkItemUpdate> updates;

  @override
  String toString() => 'WorkItemWithUpdates(item: $item, updates: $updates)';
}

class WorkItem {
  WorkItem({
    required this.id,
    this.rev,
    required this.fields,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) => WorkItem(
        id: json['id'] as int,
        rev: json['rev'] as int?,
        fields: ItemFields.fromJson(json['fields'] as Map<String, dynamic>),
      );

  static WorkItem fromResponse(Response res) => WorkItem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final int id;
  final int? rev;
  final ItemFields fields;

  @visibleForTesting
  static WorkItem empty() => WorkItem(
        id: -1,
        fields: ItemFields(
          systemWorkItemType: '',
          systemState: '',
          systemTeamProject: '',
          systemTitle: '',
          systemChangedDate: DateTime.now(),
        ),
      );

  @override
  String toString() => 'WorkItem(id: $id, rev: $rev, fields: $fields)';
}

class ItemFields {
  ItemFields({
    required this.systemTeamProject,
    required this.systemWorkItemType,
    required this.systemState,
    this.systemReason,
    this.systemAssignedTo,
    this.systemCreatedDate,
    this.systemCreatedBy,
    required this.systemChangedDate,
    this.systemChangedBy,
    this.systemCommentCount,
    required this.systemTitle,
    this.microsoftVstsCommonStateChangeDate,
    this.microsoftVstsCommonPriority,
    this.systemDescription,
    this.reproSteps,
    this.microsoftVstsCommonClosedDate,
    this.microsoftVstsCommonClosedBy,
    this.microsoftVstsCommonActivatedDate,
    this.microsoftVstsCommonActivatedBy,
    this.microsoftVstsCommonResolvedDate,
    this.systemHistory,
    this.systemTags,
  });

  factory ItemFields.fromJson(Map<String, dynamic> json) => ItemFields(
        systemTeamProject: json['System.TeamProject'] as String,
        systemWorkItemType: json['System.WorkItemType'] as String,
        systemState: json['System.State'] as String,
        systemReason: json['System.Reason'] as String?,
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : WorkItemUser.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: DateTime.parse(json['System.CreatedDate']!.toString()).toLocal(),
        systemCreatedBy: WorkItemUser.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: DateTime.parse(json['System.ChangedDate']!.toString()).toLocal(),
        systemChangedBy: json['System.ChangedBy'] == null
            ? null
            : WorkItemUser.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] as int?,
        systemTitle: json['System.Title'] as String,
        microsoftVstsCommonStateChangeDate: json['Microsoft.VSTS.Common.StateChangeDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.StateChangeDate']!.toString()).toLocal(),
        microsoftVstsCommonPriority:
            json['Microsoft.VSTS.Common.Priority'] == null ? null : json['Microsoft.VSTS.Common.Priority'] as int,
        systemDescription: json['System.Description'] as String?,
        reproSteps: json['Microsoft.VSTS.TCM.ReproSteps'] as String?,
        microsoftVstsCommonClosedDate: json['Microsoft.VSTS.Common.ClosedDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.ClosedDate']!.toString()).toLocal(),
        microsoftVstsCommonClosedBy: json['Microsoft.VSTS.Common.ClosedBy'] == null
            ? null
            : WorkItemUser.fromJson(json['Microsoft.VSTS.Common.ClosedBy'] as Map<String, dynamic>),
        microsoftVstsCommonActivatedDate: json['Microsoft.VSTS.Common.ActivatedDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.ActivatedDate']!.toString()).toLocal(),
        microsoftVstsCommonActivatedBy: json['Microsoft.VSTS.Common.ActivatedBy'] == null
            ? null
            : WorkItemUser.fromJson(json['Microsoft.VSTS.Common.ActivatedBy'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedDate: json['Microsoft.VSTS.Common.ResolvedDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.ResolvedDate']!.toString()).toLocal(),
        systemHistory: json['System.History'] as String?,
        systemTags: json['System.Tags'] as String?,
      );

  final String systemTeamProject;
  final String systemWorkItemType;
  final String systemState;
  final String? systemReason;
  final WorkItemUser? systemAssignedTo;
  final DateTime? systemCreatedDate;
  final WorkItemUser? systemCreatedBy;
  final DateTime systemChangedDate;
  final WorkItemUser? systemChangedBy;
  final int? systemCommentCount;
  final String systemTitle;
  final DateTime? microsoftVstsCommonStateChangeDate;
  final int? microsoftVstsCommonPriority;
  final String? systemDescription;
  final String? reproSteps;
  final DateTime? microsoftVstsCommonClosedDate;
  final WorkItemUser? microsoftVstsCommonClosedBy;
  final DateTime? microsoftVstsCommonActivatedDate;
  final WorkItemUser? microsoftVstsCommonActivatedBy;
  final DateTime? microsoftVstsCommonResolvedDate;
  final String? systemHistory;
  final String? systemTags;

  @override
  String toString() {
    return 'ItemFields(systemTeamProject: $systemTeamProject, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemCommentCount: $systemCommentCount, systemTitle: $systemTitle, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, systemDescription: $systemDescription, reproSteps: $reproSteps, microsoftVstsCommonClosedDate: $microsoftVstsCommonClosedDate, microsoftVstsCommonClosedBy: $microsoftVstsCommonClosedBy, microsoftVstsCommonActivatedDate: $microsoftVstsCommonActivatedDate, microsoftVstsCommonActivatedBy: $microsoftVstsCommonActivatedBy, microsoftVstsCommonResolvedDate: $microsoftVstsCommonResolvedDate, systemHistory: $systemHistory, systemTags: $systemTags)';
  }
}

class WorkItemUser {
  WorkItemUser({
    this.displayName,
    this.id,
    this.uniqueName,
    this.imageUrl,
    this.descriptor,
    this.inactive,
  });

  factory WorkItemUser.fromJson(Map<String, dynamic> json) => WorkItemUser(
        displayName: json['displayName'] as String?,
        id: json['id'] as String?,
        uniqueName: json['uniqueName'] as String?,
        imageUrl: json['imageUrl'] as String?,
        descriptor: json['descriptor'] as String?,
        inactive: json['inactive'] as bool?,
      );

  final String? displayName;
  final String? id;
  final String? uniqueName;
  final String? imageUrl;
  final String? descriptor;
  final bool? inactive;

  @override
  String toString() {
    return 'WorkItemUser(displayName: $displayName, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl, descriptor: $descriptor, inactive: $inactive)';
  }
}
