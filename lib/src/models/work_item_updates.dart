class WorkItemUpdatesResponse {
  factory WorkItemUpdatesResponse.fromJson(Map<String, dynamic> json) => WorkItemUpdatesResponse(
        count: json['count'] as int,
        updates: List<WorkItemUpdate>.from(
          (json['value'] as List<dynamic>).map((x) => WorkItemUpdate.fromJson(x as Map<String, dynamic>)),
        ),
      );

  WorkItemUpdatesResponse({
    required this.count,
    required this.updates,
  });

  final int count;
  final List<WorkItemUpdate> updates;
}

class WorkItemUpdate {
  factory WorkItemUpdate.fromJson(Map<String, dynamic> json) => WorkItemUpdate(
        id: json['id'] as int,
        workItemId: json['workItemId'] as int,
        rev: json['rev'] as int,
        revisedBy: _RevisedBy.fromJson(json['revisedBy'] as Map<String, dynamic>),
        revisedDate: DateTime.parse(json['revisedDate']!.toString()).toLocal(),
        fields: json['fields'] == null ? null : _Fields.fromJson(json['fields'] as Map<String, dynamic>),
        relations:
            json['relations'] == null ? null : WorkItemRelations.fromJson(json['relations'] as Map<String, dynamic>),
      );

  WorkItemUpdate({
    required this.id,
    required this.workItemId,
    required this.rev,
    required this.revisedBy,
    required this.revisedDate,
    required this.fields,
    this.relations,
  });

  final int id;
  final int workItemId;
  final int rev;
  final _RevisedBy revisedBy;
  final DateTime revisedDate;
  final _Fields? fields;
  final WorkItemRelations? relations;

  @override
  String toString() {
    return 'WorkItemUpdate(id: $id, workItemId: $workItemId, rev: $rev, revisedBy: $revisedBy, revisedDate: $revisedDate, relations: $relations, fields: $fields)';
  }
}

class _Fields {
  // ignore: long-method
  factory _Fields.fromJson(Map<String, dynamic> json) => _Fields(
        systemId: json['System.Id'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['System.Id'] as Map<String, dynamic>),
        systemAuthorizedDate: _StringUpdateValue.fromJson(json['System.AuthorizedDate'] as Map<String, dynamic>),
        systemRevisedDate: _StringUpdateValue.fromJson(json['System.RevisedDate'] as Map<String, dynamic>),
        systemWorkItemType: json['System.WorkItemType'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.WorkItemType'] as Map<String, dynamic>),
        systemState: json['System.State'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.State'] as Map<String, dynamic>),
        systemReason: json['System.Reason'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.Reason'] as Map<String, dynamic>),
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: json['System.CreatedDate'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.CreatedDate'] as Map<String, dynamic>),
        systemCreatedBy: json['System.CreatedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: json['System.ChangedDate'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.ChangedDate'] as Map<String, dynamic>),
        systemChangedBy: json['System.ChangedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemAuthorizedAs: json['System.AuthorizedAs'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(json['System.AuthorizedAs'] as Map<String, dynamic>),
        systemPersonId: json['System.PersonId'] == null
            ? null
            : _SystemRevClass.fromJson(json['System.PersonId'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] == null
            ? null
            : _SystemRevClass.fromJson(json['System.CommentCount'] as Map<String, dynamic>),
        systemTeamProject: json['System.TeamProject'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.TeamProject'] as Map<String, dynamic>),
        systemTitle: json['System.Title'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.Title'] as Map<String, dynamic>),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['Microsoft.VSTS.Common.Priority'] as Map<String, dynamic>),
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] == null
            ? null
            : _StringUpdateValue.fromJson(json['Microsoft.VSTS.Common.ValueArea'] as Map<String, dynamic>),
        microsoftVstsCommonStateChangeDate: json['Microsoft.VSTS.Common.StateChangeDate'] == null
            ? null
            : _StringUpdateValue.fromJson(json['Microsoft.VSTS.Common.StateChangeDate'] as Map<String, dynamic>),
        systemHistory: json['System.History'] == null
            ? null
            : _StringUpdateValue.fromJson(json['System.History'] as Map<String, dynamic>),
        microsoftVstsCommonActivatedBy: json['Microsoft.VSTS.Common.ActivatedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(
                json['Microsoft.VSTS.Common.ActivatedBy'] as Map<String, dynamic>,
              ),
        microsoftVstsCommonActivatedDate: json['Microsoft.VSTS.Common.ActivatedDate'] == null
            ? null
            : _StringUpdateValue.fromJson(json['Microsoft.VSTS.Common.ActivatedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedDate: json['Microsoft.VSTS.Common.ResolvedDate'] == null
            ? null
            : _StringUpdateValue.fromJson(json['Microsoft.VSTS.Common.ResolvedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedBy: json['Microsoft.VSTS.Common.ResolvedBy'] == null
            ? null
            : _RevisedByUpdateValue.fromJson(
                json['Microsoft.VSTS.Common.ResolvedBy'] as Map<String, dynamic>,
              ),
        microsoftVstsSchedulingEffort: json['Microsoft.VSTS.Scheduling.Effort'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['Microsoft.VSTS.Scheduling.Effort'] as Map<String, dynamic>),
      );

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

  final _MicrosoftVstsCommonPriority? systemId;
  final _StringUpdateValue systemAuthorizedDate;
  final _StringUpdateValue systemRevisedDate;
  final _StringUpdateValue? systemWorkItemType;
  final _StringUpdateValue? systemState;
  final _StringUpdateValue? systemReason;
  final _RevisedByUpdateValue? systemAssignedTo;
  final _StringUpdateValue? systemCreatedDate;
  final _RevisedByUpdateValue? systemCreatedBy;
  final _StringUpdateValue? systemChangedDate;
  final _RevisedByUpdateValue? systemChangedBy;
  final _RevisedByUpdateValue? systemAuthorizedAs;
  final _SystemRevClass? systemPersonId;
  final _SystemRevClass? systemCommentCount;
  final _StringUpdateValue? systemTeamProject;
  final _StringUpdateValue? systemTitle;
  final _MicrosoftVstsCommonPriority? microsoftVstsCommonPriority;
  final _StringUpdateValue? microsoftVstsCommonValueArea;
  final _StringUpdateValue? microsoftVstsCommonStateChangeDate;
  final _StringUpdateValue? systemHistory;
  final _RevisedByUpdateValue? microsoftVstsCommonActivatedBy;
  final _StringUpdateValue? microsoftVstsCommonActivatedDate;
  final _StringUpdateValue? microsoftVstsCommonResolvedDate;
  final _RevisedByUpdateValue? microsoftVstsCommonResolvedBy;
  final _MicrosoftVstsCommonPriority? microsoftVstsSchedulingEffort;

  @override
  String toString() {
    return 'Fields(systemId: $systemId, systemAuthorizedDate: $systemAuthorizedDate, systemRevisedDate: $systemRevisedDate, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemAuthorizedAs: $systemAuthorizedAs, systemPersonId: $systemPersonId, systemCommentCount: $systemCommentCount, systemTeamProject: $systemTeamProject, systemTitle: $systemTitle, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, microsoftVstsCommonValueArea: $microsoftVstsCommonValueArea, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, systemHistory: $systemHistory, microsoftVstsCommonActivatedBy: $microsoftVstsCommonActivatedBy, microsoftVstsCommonActivatedDate: $microsoftVstsCommonActivatedDate, microsoftVstsCommonResolvedDate: $microsoftVstsCommonResolvedDate, microsoftVstsCommonResolvedBy: $microsoftVstsCommonResolvedBy, microsoftVstsSchedulingEffort: $microsoftVstsSchedulingEffort)';
  }
}

class _RevisedByUpdateValue {
  factory _RevisedByUpdateValue.fromJson(Map<String, dynamic> json) => _RevisedByUpdateValue(
        newValue: json['newValue'] == null ? null : _RevisedBy.fromJson(json['newValue'] as Map<String, dynamic>),
        oldValue: json['oldValue'] == null ? null : _RevisedBy.fromJson(json['oldValue'] as Map<String, dynamic>),
      );

  _RevisedByUpdateValue({
    this.newValue,
    this.oldValue,
  });

  final _RevisedBy? newValue;
  final _RevisedBy? oldValue;
}

class _RevisedBy {
  factory _RevisedBy.fromJson(Map<String, dynamic> json) => _RevisedBy(
        displayName: json['displayName'] as String?,
        id: json['id'] as String?,
        uniqueName: json['uniqueName'] as String?,
        imageUrl: json['imageUrl'] as String?,
        descriptor: json['descriptor'] as String?,
        name: json['name'] as String?,
      );

  _RevisedBy({
    this.displayName,
    this.id,
    this.uniqueName,
    this.imageUrl,
    this.descriptor,
    this.name,
  });

  final String? displayName;
  final String? id;
  final String? uniqueName;
  final String? imageUrl;
  final String? descriptor;
  final String? name;
}

class _MicrosoftVstsCommonPriority {
  factory _MicrosoftVstsCommonPriority.fromJson(Map<String, dynamic> json) => _MicrosoftVstsCommonPriority(
        oldValue: (json['oldValue'] as num?)?.toDouble(),
        newValue: (json['newValue'] as num?)?.toDouble(),
      );

  _MicrosoftVstsCommonPriority({
    required this.oldValue,
    required this.newValue,
  });

  final double? oldValue;
  final double? newValue;
}

class _StringUpdateValue {
  factory _StringUpdateValue.fromJson(Map<String, dynamic> json) => _StringUpdateValue(
        oldValue: json['oldValue'] as String?,
        newValue: json['newValue'] as String?,
      );

  _StringUpdateValue({
    required this.oldValue,
    required this.newValue,
  });

  final String? oldValue;
  final String? newValue;
}

class _SystemRevClass {
  factory _SystemRevClass.fromJson(Map<String, dynamic> json) => _SystemRevClass(
        newValue: json['newValue'] as int?,
        oldValue: json['oldValue'] as int?,
      );

  _SystemRevClass({
    required this.newValue,
    this.oldValue,
  });

  final int? newValue;
  final int? oldValue;
}

class WorkItemRelations {
  WorkItemRelations({this.added, this.removed, this.updated});

  factory WorkItemRelations.fromJson(Map<String, dynamic> json) => WorkItemRelations(
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
  });

  factory _Attributes.fromJson(Map<String, dynamic> json) => _Attributes(
        id: json['id'] as int?,
        resourceSize: json['resourceSize'] as int?,
        name: json['name'] as String?,
      );

  final int? id;
  final int? resourceSize;
  final String? name;

  @override
  String toString() {
    return '_Attributes(id: $id, resourceSize: $resourceSize, name: $name)';
  }
}
