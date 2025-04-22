import 'dart:convert';

import 'package:http/http.dart';

class WorkItemUpdatesResponse {
  WorkItemUpdatesResponse({
    required this.count,
    required this.updates,
  });

  factory WorkItemUpdatesResponse.fromJson(Map<String, dynamic> json) => WorkItemUpdatesResponse(
        count: json['count'] as int,
        updates: List<WorkItemUpdate>.from(
          (json['value'] as List<dynamic>).map((x) => WorkItemUpdate.fromJson(x as Map<String, dynamic>)),
        ),
      );

  static List<WorkItemUpdate> fromResponse(Response res) =>
      WorkItemUpdatesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).updates;

  final int count;
  final List<WorkItemUpdate> updates;
}

class WorkItemUpdate {
  WorkItemUpdate({
    required this.id,
    required this.workItemId,
    required this.rev,
    required this.revisedBy,
    required this.revisedDate,
    required this.fields,
    this.relations,
  });

  factory WorkItemUpdate.fromJson(Map<String, dynamic> json) => WorkItemUpdate(
        id: json['id'] as int,
        workItemId: json['workItemId'] as int,
        rev: json['rev'] as int,
        revisedBy: _RevisedBy.fromJson(json['revisedBy'] as Map<String, dynamic>),
        revisedDate: DateTime.parse(json['revisedDate']!.toString()).toLocal(),
        fields: json['fields'] == null ? null : _Fields.fromJson(json['fields'] as Map<String, dynamic>),
        relations:
            json['relations'] == null ? null : _WorkItemRelations.fromJson(json['relations'] as Map<String, dynamic>),
      );

  final int id;
  final int workItemId;
  final int rev;
  final _RevisedBy revisedBy;
  final DateTime revisedDate;
  final _Fields? fields;
  final _WorkItemRelations? relations;

  @override
  String toString() {
    return 'WorkItemUpdate(id: $id, workItemId: $workItemId, rev: $rev, revisedBy: $revisedBy, revisedDate: $revisedDate, relations: $relations, fields: $fields)';
  }
}

class _Fields {
  _Fields({
    this.systemId,
    required this.systemAuthorizedDate,
    required this.systemRevisedDate,
    this.systemWorkItemType,
    this.systemState,
    this.systemReason,
    this.systemAssignedTo,
    this.systemCreatedDate,
    this.systemCreatedBy,
    required this.systemChangedDate,
    this.systemChangedBy,
    this.systemAuthorizedAs,
    this.systemPersonId,
    this.systemCommentCount,
    this.systemTeamProject,
    this.systemTitle,
    this.microsoftVstsCommonPriority,
    this.microsoftVstsCommonValueArea,
    this.microsoftVstsCommonStateChangeDate,
    this.systemHistory,
    this.microsoftVstsCommonActivatedBy,
    this.microsoftVstsCommonActivatedDate,
    this.microsoftVstsCommonResolvedDate,
    this.microsoftVstsCommonResolvedBy,
    this.microsoftVstsSchedulingEffort,
  });

  // ignore: long-method
  factory _Fields.fromJson(Map<String, dynamic> json) => _Fields(
        systemId: json['System.Id'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['System.Id'] as Map<String, dynamic>),
        systemAuthorizedDate: _ChangedField.fromJson(json['System.AuthorizedDate'] as Map<String, dynamic>),
        systemRevisedDate: _ChangedField.fromJson(json['System.RevisedDate'] as Map<String, dynamic>),
        systemWorkItemType: json['System.WorkItemType'] == null
            ? null
            : _ChangedField.fromJson(json['System.WorkItemType'] as Map<String, dynamic>),
        systemState:
            json['System.State'] == null ? null : _ChangedField.fromJson(json['System.State'] as Map<String, dynamic>),
        systemReason: json['System.Reason'] == null
            ? null
            : _ChangedField.fromJson(json['System.Reason'] as Map<String, dynamic>),
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: json['System.CreatedDate'] == null
            ? null
            : _ChangedField.fromJson(json['System.CreatedDate'] as Map<String, dynamic>),
        systemCreatedBy: json['System.CreatedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: json['System.ChangedDate'] == null
            ? null
            : _ChangedField.fromJson(json['System.ChangedDate'] as Map<String, dynamic>),
        systemChangedBy: json['System.ChangedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemAuthorizedAs: json['System.AuthorizedAs'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.AuthorizedAs'] as Map<String, dynamic>),
        systemPersonId: json['System.PersonId'] == null
            ? null
            : _ChangedField.fromJson(json['System.PersonId'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] == null
            ? null
            : _ChangedField.fromJson(json['System.CommentCount'] as Map<String, dynamic>),
        systemTeamProject: json['System.TeamProject'] == null
            ? null
            : _ChangedField.fromJson(json['System.TeamProject'] as Map<String, dynamic>),
        systemTitle:
            json['System.Title'] == null ? null : _ChangedField.fromJson(json['System.Title'] as Map<String, dynamic>),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['Microsoft.VSTS.Common.Priority'] as Map<String, dynamic>),
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] == null
            ? null
            : _ChangedField.fromJson(json['Microsoft.VSTS.Common.ValueArea'] as Map<String, dynamic>),
        microsoftVstsCommonStateChangeDate: json['Microsoft.VSTS.Common.StateChangeDate'] == null
            ? null
            : _ChangedField.fromJson(json['Microsoft.VSTS.Common.StateChangeDate'] as Map<String, dynamic>),
        systemHistory: json['System.History'] == null
            ? null
            : _ChangedField.fromJson(json['System.History'] as Map<String, dynamic>),
        microsoftVstsCommonActivatedBy: json['Microsoft.VSTS.Common.ActivatedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(
                json['Microsoft.VSTS.Common.ActivatedBy'] as Map<String, dynamic>,
              ),
        microsoftVstsCommonActivatedDate: json['Microsoft.VSTS.Common.ActivatedDate'] == null
            ? null
            : _ChangedField.fromJson(json['Microsoft.VSTS.Common.ActivatedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedDate: json['Microsoft.VSTS.Common.ResolvedDate'] == null
            ? null
            : _ChangedField.fromJson(json['Microsoft.VSTS.Common.ResolvedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedBy: json['Microsoft.VSTS.Common.ResolvedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(
                json['Microsoft.VSTS.Common.ResolvedBy'] as Map<String, dynamic>,
              ),
        microsoftVstsSchedulingEffort: json['Microsoft.VSTS.Scheduling.Effort'] == null
            ? null
            : _ChangedField.fromJson(json['Microsoft.VSTS.Scheduling.Effort'] as Map<String, dynamic>),
      );

  final _MicrosoftVstsCommonPriority? systemId;
  final _ChangedField<String> systemAuthorizedDate;
  final _ChangedField<String> systemRevisedDate;
  final _ChangedField<String>? systemWorkItemType;
  final _ChangedField<String>? systemState;
  final _ChangedField<String>? systemReason;
  final _RevisedByUpdateValue? systemAssignedTo;
  final _ChangedField<String>? systemCreatedDate;
  final _RevisedByUpdateValue? systemCreatedBy;
  final _ChangedField<String>? systemChangedDate;
  final _RevisedByUpdateValue? systemChangedBy;
  final _RevisedByUpdateValue? systemAuthorizedAs;
  final _ChangedField<int>? systemPersonId;
  final _ChangedField<int>? systemCommentCount;
  final _ChangedField<String>? systemTeamProject;
  final _ChangedField<String>? systemTitle;
  final _MicrosoftVstsCommonPriority? microsoftVstsCommonPriority;
  final _ChangedField<String>? microsoftVstsCommonValueArea;
  final _ChangedField<String>? microsoftVstsCommonStateChangeDate;
  final _ChangedField<String>? systemHistory;
  final _RevisedByUpdateValue? microsoftVstsCommonActivatedBy;
  final _ChangedField<String>? microsoftVstsCommonActivatedDate;
  final _ChangedField<String>? microsoftVstsCommonResolvedDate;
  final _RevisedByUpdateValue? microsoftVstsCommonResolvedBy;
  final _ChangedField<double>? microsoftVstsSchedulingEffort;

  @override
  String toString() {
    return 'Fields(systemId: $systemId, systemAuthorizedDate: $systemAuthorizedDate, systemRevisedDate: $systemRevisedDate, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemAuthorizedAs: $systemAuthorizedAs, systemPersonId: $systemPersonId, systemCommentCount: $systemCommentCount, systemTeamProject: $systemTeamProject, systemTitle: $systemTitle, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, microsoftVstsCommonValueArea: $microsoftVstsCommonValueArea, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, systemHistory: $systemHistory, microsoftVstsCommonActivatedBy: $microsoftVstsCommonActivatedBy, microsoftVstsCommonActivatedDate: $microsoftVstsCommonActivatedDate, microsoftVstsCommonResolvedDate: $microsoftVstsCommonResolvedDate, microsoftVstsCommonResolvedBy: $microsoftVstsCommonResolvedBy, microsoftVstsSchedulingEffort: $microsoftVstsSchedulingEffort)';
  }
}

class _RevisedByUpdateValue {
  _RevisedByUpdateValue({
    this.newValue,
    this.oldValue,
  });

  factory _RevisedByUpdateValue.fromJson(Map<String, dynamic> json) => _RevisedByUpdateValue(
        newValue: json['newValue'] == null ? null : _RevisedBy.fromJson(json['newValue'] as Map<String, dynamic>),
        oldValue: json['oldValue'] == null ? null : _RevisedBy.fromJson(json['oldValue'] as Map<String, dynamic>),
      );

  final _RevisedBy? newValue;
  final _RevisedBy? oldValue;
}

class _RevisedBy {
  _RevisedBy({
    this.displayName,
    this.id,
    this.uniqueName,
    this.imageUrl,
    this.descriptor,
    this.name,
  });

  factory _RevisedBy.fromJson(Map<String, dynamic> json) => _RevisedBy(
        displayName: json['displayName'] as String?,
        id: json['id'] as String?,
        uniqueName: json['uniqueName'] as String?,
        imageUrl: json['imageUrl'] as String?,
        descriptor: json['descriptor'] as String?,
        name: json['name'] as String?,
      );

  final String? displayName;
  final String? id;
  final String? uniqueName;
  final String? imageUrl;
  final String? descriptor;
  final String? name;
}

class _MicrosoftVstsCommonPriority {
  _MicrosoftVstsCommonPriority({
    required this.oldValue,
    required this.newValue,
  });

  factory _MicrosoftVstsCommonPriority.fromJson(Map<String, dynamic> json) => _MicrosoftVstsCommonPriority(
        oldValue: (json['oldValue'] as num?)?.toDouble(),
        newValue: (json['newValue'] as num?)?.toDouble(),
      );

  final double? oldValue;
  final double? newValue;
}

class _WorkItemRelations {
  _WorkItemRelations({this.added, this.removed, this.updated});

  factory _WorkItemRelations.fromJson(Map<String, dynamic> json) => _WorkItemRelations(
        added: List<Relation>.from(
          (json['added'] as List<dynamic>? ?? []).map((r) => Relation.fromJson(r as Map<String, dynamic>)),
        ),
        removed: List<Relation>.from(
          (json['removed'] as List<dynamic>? ?? []).map((r) => Relation.fromJson(r as Map<String, dynamic>)),
        ),
        updated: List<Relation>.from(
          (json['updated'] as List<dynamic>? ?? []).map((r) => Relation.fromJson(r as Map<String, dynamic>)),
        ),
      );

  final List<Relation>? added;
  final List<Relation>? removed;
  final List<Relation>? updated;

  @override
  String toString() => '_Relations(added: $added, removed: $removed, updated: $updated)';
}

class Relation {
  Relation({required this.rel, this.url, required this.attributes});

  factory Relation.fromJson(Map<String, dynamic> json) => Relation(
        rel: json['rel'] as String?,
        url: json['url'] as String?,
        attributes:
            json['attributes'] == null ? null : _Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
      );

  final String? rel;
  final String? url;
  final _Attributes? attributes;

  @override
  String toString() => '_Relation(rel: $rel, url: $url, attributes: $attributes)';
}

class _Attributes {
  _Attributes({
    this.id,
    this.resourceSize,
    this.name,
    this.comment,
  });

  factory _Attributes.fromJson(Map<String, dynamic> json) => _Attributes(
        id: json['id'] as int?,
        resourceSize: json['resourceSize'] as int?,
        name: json['name'] as String?,
        comment: json['comment'] as String?,
      );

  final int? id;
  final int? resourceSize;
  final String? name;
  final String? comment;

  @override
  String toString() {
    return '_Attributes(id: $id, resourceSize: $resourceSize, name: $name, comment: $comment)';
  }
}

sealed class ItemUpdate {
  ItemUpdate({required this.updateDate, required this.updatedBy});

  final DateTime updateDate;
  final UpdateUser updatedBy;
}

class SimpleItemUpdate extends ItemUpdate {
  SimpleItemUpdate({
    required super.updateDate,
    required super.updatedBy,
    required this.isFirst,
    this.type,
    this.state,
    this.assignedTo,
    this.effort,
    this.title,
    this.relations,
  });

  final bool isFirst;
  _ChangedField<String>? type;
  _ChangedField<String>? state;
  _RevisedByUpdateValue? assignedTo;
  _ChangedField<double>? effort;
  _ChangedField<String>? title;
  _WorkItemRelations? relations;
}

class CommentItemUpdate extends ItemUpdate {
  CommentItemUpdate({
    required super.updateDate,
    required super.updatedBy,
    required this.workItemId,
    required this.id,
    required this.text,
    this.isEdited = false,
    required this.format,
  });

  final int workItemId;
  final int id;
  String text;
  final bool isEdited;
  final String format;
}

class LinkUpdate extends ItemUpdate {
  LinkUpdate({
    required super.updateDate,
    required super.updatedBy,
    required this.relations,
  });

  _WorkItemRelations relations;
}

final class UpdateUser {
  UpdateUser({required this.descriptor, required this.displayName});

  final String descriptor;
  final String displayName;
}

final class _ChangedField<T> {
  _ChangedField({required this.oldValue, required this.newValue});

  factory _ChangedField.fromJson(Map<String, dynamic> json) => _ChangedField(
        oldValue: json['oldValue'] as T?,
        newValue: json['newValue'] as T?,
      );

  final T? oldValue;
  final T? newValue;
}
