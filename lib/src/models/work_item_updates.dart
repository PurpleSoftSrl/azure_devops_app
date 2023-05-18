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
        url: json['url'] as String,
      );

  WorkItemUpdate({
    required this.id,
    required this.workItemId,
    required this.rev,
    required this.revisedBy,
    required this.revisedDate,
    required this.fields,
    required this.url,
  });

  final int id;
  final int workItemId;
  final int rev;
  final _RevisedBy revisedBy;
  final DateTime revisedDate;
  final _Fields? fields;
  final String url;

  @override
  String toString() {
    return 'WorkItemUpdate(id: $id, workItemId: $workItemId, rev: $rev, revisedBy: $revisedBy, revisedDate: $revisedDate, fields: $fields, url: $url)';
  }
}

class _Fields {
  // ignore: long-method
  factory _Fields.fromJson(Map<String, dynamic> json) => _Fields(
        systemId: json['System.Id'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['System.Id'] as Map<String, dynamic>),
        systemAreaId: json['System.AreaId'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['System.AreaId'] as Map<String, dynamic>),
        systemNodeName: json['System.NodeName'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.NodeName'] as Map<String, dynamic>),
        systemAreaLevel1: json['System.AreaLevel1'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.AreaLevel1'] as Map<String, dynamic>),
        systemRev: _SystemRevClass.fromJson(json['System.Rev'] as Map<String, dynamic>),
        systemAuthorizedDate: _SystemAuthorizedDate.fromJson(json['System.AuthorizedDate'] as Map<String, dynamic>),
        systemRevisedDate: _SystemAuthorizedDate.fromJson(json['System.RevisedDate'] as Map<String, dynamic>),
        systemIterationId: json['System.IterationId'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['System.IterationId'] as Map<String, dynamic>),
        systemIterationLevel1: json['System.IterationLevel1'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.IterationLevel1'] as Map<String, dynamic>),
        systemWorkItemType: json['System.WorkItemType'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.WorkItemType'] as Map<String, dynamic>),
        systemState: json['System.State'] == null
            ? null
            : _SystemAuthorizedDate.fromJson(json['System.State'] as Map<String, dynamic>),
        systemReason: json['System.Reason'] == null
            ? null
            : _SystemAuthorizedDate.fromJson(json['System.Reason'] as Map<String, dynamic>),
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : _SystemAssignedToClass.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: json['System.CreatedDate'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.CreatedDate'] as Map<String, dynamic>),
        systemCreatedBy: json['System.CreatedBy'] == null
            ? null
            : _SystemAssignedToClass.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: json['System.ChangedDate'] == null
            ? null
            : _SystemAuthorizedDate.fromJson(json['System.ChangedDate'] as Map<String, dynamic>),
        systemChangedBy: json['System.ChangedBy'] == null
            ? null
            : _MicrosoftVstsCommonActivatedBy.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemAuthorizedAs: json['System.AuthorizedAs'] == null
            ? null
            : _MicrosoftVstsCommonActivatedBy.fromJson(json['System.AuthorizedAs'] as Map<String, dynamic>),
        systemPersonId: json['System.PersonId'] == null
            ? null
            : _SystemRevClass.fromJson(json['System.PersonId'] as Map<String, dynamic>),
        systemWatermark: _SystemRevClass.fromJson(json['System.Watermark'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] == null
            ? null
            : _SystemRevClass.fromJson(json['System.CommentCount'] as Map<String, dynamic>),
        systemTeamProject: json['System.TeamProject'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.TeamProject'] as Map<String, dynamic>),
        systemAreaPath: json['System.AreaPath'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.AreaPath'] as Map<String, dynamic>),
        systemIterationPath: json['System.IterationPath'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.IterationPath'] as Map<String, dynamic>),
        systemTitle: json['System.Title'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['System.Title'] as Map<String, dynamic>),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['Microsoft.VSTS.Common.Priority'] as Map<String, dynamic>),
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] == null
            ? null
            : _MicrosoftVstsCommonValueArea.fromJson(json['Microsoft.VSTS.Common.ValueArea'] as Map<String, dynamic>),
        microsoftVstsCommonStateChangeDate: json['Microsoft.VSTS.Common.StateChangeDate'] == null
            ? null
            : _SystemAuthorizedDate.fromJson(json['Microsoft.VSTS.Common.StateChangeDate'] as Map<String, dynamic>),
        systemHistory: json['System.History'] == null
            ? null
            : _SystemAuthorizedDate.fromJson(json['System.History'] as Map<String, dynamic>),
        microsoftVstsCommonActivatedBy: json['Microsoft.VSTS.Common.ActivatedBy'] == null
            ? null
            : _MicrosoftVstsCommonActivatedBy.fromJson(
                json['Microsoft.VSTS.Common.ActivatedBy'] as Map<String, dynamic>,
              ),
        microsoftVstsCommonActivatedDate: json['Microsoft.VSTS.Common.ActivatedDate'] == null
            ? null
            : _SystemAuthorizedDate.fromJson(json['Microsoft.VSTS.Common.ActivatedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedDate: json['Microsoft.VSTS.Common.ResolvedDate'] == null
            ? null
            : _SystemAuthorizedDate.fromJson(json['Microsoft.VSTS.Common.ResolvedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedBy: json['Microsoft.VSTS.Common.ResolvedBy'] == null
            ? null
            : _MicrosoftVstsCommonActivatedBy.fromJson(
                json['Microsoft.VSTS.Common.ResolvedBy'] as Map<String, dynamic>,
              ),
        microsoftVstsSchedulingEffort: json['Microsoft.VSTS.Scheduling.Effort'] == null
            ? null
            : _MicrosoftVstsCommonPriority.fromJson(json['Microsoft.VSTS.Scheduling.Effort'] as Map<String, dynamic>),
      );

  _Fields({
    this.systemId,
    this.systemAreaId,
    this.systemNodeName,
    this.systemAreaLevel1,
    required this.systemRev,
    required this.systemAuthorizedDate,
    required this.systemRevisedDate,
    this.systemIterationId,
    this.systemIterationLevel1,
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
    required this.systemWatermark,
    this.systemCommentCount,
    this.systemTeamProject,
    this.systemAreaPath,
    this.systemIterationPath,
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
  final _MicrosoftVstsCommonPriority? systemAreaId;
  final _MicrosoftVstsCommonValueArea? systemNodeName;
  final _MicrosoftVstsCommonValueArea? systemAreaLevel1;
  final _SystemRevClass systemRev;
  final _SystemAuthorizedDate systemAuthorizedDate;
  final _SystemAuthorizedDate systemRevisedDate;
  final _MicrosoftVstsCommonPriority? systemIterationId;
  final _MicrosoftVstsCommonValueArea? systemIterationLevel1;
  final _MicrosoftVstsCommonValueArea? systemWorkItemType;
  final _SystemAuthorizedDate? systemState;
  final _SystemAuthorizedDate? systemReason;
  final _SystemAssignedToClass? systemAssignedTo;
  final _MicrosoftVstsCommonValueArea? systemCreatedDate;
  final _SystemAssignedToClass? systemCreatedBy;
  final _SystemAuthorizedDate? systemChangedDate;
  final _MicrosoftVstsCommonActivatedBy? systemChangedBy;
  final _MicrosoftVstsCommonActivatedBy? systemAuthorizedAs;
  final _SystemRevClass? systemPersonId;
  final _SystemRevClass systemWatermark;
  final _SystemRevClass? systemCommentCount;
  final _MicrosoftVstsCommonValueArea? systemTeamProject;
  final _MicrosoftVstsCommonValueArea? systemAreaPath;
  final _MicrosoftVstsCommonValueArea? systemIterationPath;
  final _MicrosoftVstsCommonValueArea? systemTitle;
  final _MicrosoftVstsCommonPriority? microsoftVstsCommonPriority;
  final _MicrosoftVstsCommonValueArea? microsoftVstsCommonValueArea;
  final _SystemAuthorizedDate? microsoftVstsCommonStateChangeDate;
  final _SystemAuthorizedDate? systemHistory;
  final _MicrosoftVstsCommonActivatedBy? microsoftVstsCommonActivatedBy;
  final _SystemAuthorizedDate? microsoftVstsCommonActivatedDate;
  final _SystemAuthorizedDate? microsoftVstsCommonResolvedDate;
  final _MicrosoftVstsCommonActivatedBy? microsoftVstsCommonResolvedBy;
  final _MicrosoftVstsCommonPriority? microsoftVstsSchedulingEffort;

  @override
  String toString() {
    return 'Fields(systemId: $systemId, systemAreaId: $systemAreaId, systemNodeName: $systemNodeName, systemAreaLevel1: $systemAreaLevel1, systemRev: $systemRev, systemAuthorizedDate: $systemAuthorizedDate, systemRevisedDate: $systemRevisedDate, systemIterationId: $systemIterationId, systemIterationLevel1: $systemIterationLevel1, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemAuthorizedAs: $systemAuthorizedAs, systemPersonId: $systemPersonId, systemWatermark: $systemWatermark, systemCommentCount: $systemCommentCount, systemTeamProject: $systemTeamProject, systemAreaPath: $systemAreaPath, systemIterationPath: $systemIterationPath, systemTitle: $systemTitle, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, microsoftVstsCommonValueArea: $microsoftVstsCommonValueArea, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, systemHistory: $systemHistory, microsoftVstsCommonActivatedBy: $microsoftVstsCommonActivatedBy, microsoftVstsCommonActivatedDate: $microsoftVstsCommonActivatedDate, microsoftVstsCommonResolvedDate: $microsoftVstsCommonResolvedDate, microsoftVstsCommonResolvedBy: $microsoftVstsCommonResolvedBy, microsoftVstsSchedulingEffort: $microsoftVstsSchedulingEffort)';
  }
}

class _MicrosoftVstsCommonActivatedBy {
  factory _MicrosoftVstsCommonActivatedBy.fromJson(Map<String, dynamic> json) => _MicrosoftVstsCommonActivatedBy(
        newValue: json['newValue'] == null ? null : _RevisedBy.fromJson(json['newValue'] as Map<String, dynamic>),
        oldValue: json['oldValue'] == null ? null : _RevisedBy.fromJson(json['oldValue'] as Map<String, dynamic>),
      );

  _MicrosoftVstsCommonActivatedBy({
    this.newValue,
    this.oldValue,
  });

  final _RevisedBy? newValue;
  final _RevisedBy? oldValue;
}

class _RevisedBy {
  factory _RevisedBy.fromJson(Map<String, dynamic> json) => _RevisedBy(
        displayName: json['displayName'] as String,
        url: json['url'] as String,
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
        name: json['name'] as String?,
      );

  _RevisedBy({
    required this.displayName,
    required this.url,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
    this.name,
  });

  final String displayName;
  final String url;
  final String id;
  final String uniqueName;
  final String imageUrl;
  final String descriptor;
  final String? name;
}

class _SystemAuthorizedDate {
  factory _SystemAuthorizedDate.fromJson(Map<String, dynamic> json) => _SystemAuthorizedDate(
        newValue: json['newValue'] as String?,
        oldValue: json['oldValue'] as String?,
      );

  _SystemAuthorizedDate({
    this.newValue,
    this.oldValue,
  });

  final String? newValue;
  final String? oldValue;
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

class _MicrosoftVstsCommonValueArea {
  factory _MicrosoftVstsCommonValueArea.fromJson(Map<String, dynamic> json) => _MicrosoftVstsCommonValueArea(
        oldValue: json['oldValue'] as String?,
        newValue: json['newValue'] as String?,
      );

  _MicrosoftVstsCommonValueArea({
    required this.oldValue,
    required this.newValue,
  });

  final String? oldValue;
  final String? newValue;
}

class _SystemAssignedToClass {
  factory _SystemAssignedToClass.fromJson(Map<String, dynamic> json) => _SystemAssignedToClass(
        oldValue: json['oldValue'] == null ? null : _RevisedBy.fromJson(json['oldValue'] as Map<String, dynamic>),
        newValue: json['newValue'] == null ? null : _RevisedBy.fromJson(json['newValue'] as Map<String, dynamic>),
      );

  _SystemAssignedToClass({
    this.oldValue,
    this.newValue,
  });

  final _RevisedBy? oldValue;
  final _RevisedBy? newValue;
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
