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
        revisedBy: RevisedBy.fromJson(json['revisedBy'] as Map<String, dynamic>),
        revisedDate: DateTime.parse(json['revisedDate']!.toString()).toLocal(),
        fields: json['fields'] == null ? null : Fields.fromJson(json['fields'] as Map<String, dynamic>),
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
  final RevisedBy revisedBy;
  final DateTime revisedDate;
  final Fields? fields;
  final String url;

  @override
  String toString() {
    return 'WorkItemUpdate(id: $id, workItemId: $workItemId, rev: $rev, revisedBy: $revisedBy, revisedDate: $revisedDate, fields: $fields, url: $url)';
  }
}

class Fields {
  // ignore: long-method
  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        systemId: json['System.Id'] == null
            ? null
            : MicrosoftVstsCommonPriority.fromJson(json['System.Id'] as Map<String, dynamic>),
        systemAreaId: json['System.AreaId'] == null
            ? null
            : MicrosoftVstsCommonPriority.fromJson(json['System.AreaId'] as Map<String, dynamic>),
        systemNodeName: json['System.NodeName'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.NodeName'] as Map<String, dynamic>),
        systemAreaLevel1: json['System.AreaLevel1'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.AreaLevel1'] as Map<String, dynamic>),
        systemRev: SystemRevClass.fromJson(json['System.Rev'] as Map<String, dynamic>),
        systemAuthorizedDate: SystemAuthorizedDate.fromJson(json['System.AuthorizedDate'] as Map<String, dynamic>),
        systemRevisedDate: SystemAuthorizedDate.fromJson(json['System.RevisedDate'] as Map<String, dynamic>),
        systemIterationId: json['System.IterationId'] == null
            ? null
            : MicrosoftVstsCommonPriority.fromJson(json['System.IterationId'] as Map<String, dynamic>),
        systemIterationLevel1: json['System.IterationLevel1'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.IterationLevel1'] as Map<String, dynamic>),
        systemWorkItemType: json['System.WorkItemType'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.WorkItemType'] as Map<String, dynamic>),
        systemState: json['System.State'] == null
            ? null
            : SystemAuthorizedDate.fromJson(json['System.State'] as Map<String, dynamic>),
        systemReason: json['System.Reason'] == null
            ? null
            : SystemAuthorizedDate.fromJson(json['System.Reason'] as Map<String, dynamic>),
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : SystemAssignedToClass.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: json['System.CreatedDate'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.CreatedDate'] as Map<String, dynamic>),
        systemCreatedBy: json['System.CreatedBy'] == null
            ? null
            : SystemAssignedToClass.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: json['System.ChangedDate'] == null
            ? null
            : SystemAuthorizedDate.fromJson(json['System.ChangedDate'] as Map<String, dynamic>),
        systemChangedBy: json['System.ChangedBy'] == null
            ? null
            : MicrosoftVstsCommonActivatedBy.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemAuthorizedAs: json['System.AuthorizedAs'] == null
            ? null
            : MicrosoftVstsCommonActivatedBy.fromJson(json['System.AuthorizedAs'] as Map<String, dynamic>),
        systemPersonId: json['System.PersonId'] == null
            ? null
            : SystemRevClass.fromJson(json['System.PersonId'] as Map<String, dynamic>),
        systemWatermark: SystemRevClass.fromJson(json['System.Watermark'] as Map<String, dynamic>),
        systemIsDeleted: json['System.IsDeleted'] == null
            ? null
            : SystemBoardColumnDone.fromJson(json['System.IsDeleted'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] == null
            ? null
            : SystemRevClass.fromJson(json['System.CommentCount'] as Map<String, dynamic>),
        systemTeamProject: json['System.TeamProject'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.TeamProject'] as Map<String, dynamic>),
        systemAreaPath: json['System.AreaPath'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.AreaPath'] as Map<String, dynamic>),
        systemIterationPath: json['System.IterationPath'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.IterationPath'] as Map<String, dynamic>),
        systemTitle: json['System.Title'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['System.Title'] as Map<String, dynamic>),
        systemBoardColumnDone: json['System.BoardColumnDone'] == null
            ? null
            : SystemBoardColumnDone.fromJson(json['System.BoardColumnDone'] as Map<String, dynamic>),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] == null
            ? null
            : MicrosoftVstsCommonPriority.fromJson(json['Microsoft.VSTS.Common.Priority'] as Map<String, dynamic>),
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] == null
            ? null
            : MicrosoftVstsCommonValueArea.fromJson(json['Microsoft.VSTS.Common.ValueArea'] as Map<String, dynamic>),
        microsoftVstsCommonStateChangeDate: json['Microsoft.VSTS.Common.StateChangeDate'] == null
            ? null
            : SystemAuthorizedDate.fromJson(json['Microsoft.VSTS.Common.StateChangeDate'] as Map<String, dynamic>),
        systemHistory: json['System.History'] == null
            ? null
            : SystemAuthorizedDate.fromJson(json['System.History'] as Map<String, dynamic>),
        microsoftVstsCommonActivatedBy: json['Microsoft.VSTS.Common.ActivatedBy'] == null
            ? null
            : MicrosoftVstsCommonActivatedBy.fromJson(
                json['Microsoft.VSTS.Common.ActivatedBy'] as Map<String, dynamic>,
              ),
        microsoftVstsCommonActivatedDate: json['Microsoft.VSTS.Common.ActivatedDate'] == null
            ? null
            : SystemAuthorizedDate.fromJson(json['Microsoft.VSTS.Common.ActivatedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedDate: json['Microsoft.VSTS.Common.ResolvedDate'] == null
            ? null
            : SystemAuthorizedDate.fromJson(json['Microsoft.VSTS.Common.ResolvedDate'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedBy: json['Microsoft.VSTS.Common.ResolvedBy'] == null
            ? null
            : MicrosoftVstsCommonActivatedBy.fromJson(json['Microsoft.VSTS.Common.ResolvedBy'] as Map<String, dynamic>),
        microsoftVstsSchedulingEffort: json['Microsoft.VSTS.Scheduling.Effort'] == null
            ? null
            : MicrosoftVstsCommonPriority.fromJson(json['Microsoft.VSTS.Scheduling.Effort'] as Map<String, dynamic>),
      );

  Fields({
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
    this.systemIsDeleted,
    this.systemCommentCount,
    this.systemTeamProject,
    this.systemAreaPath,
    this.systemIterationPath,
    this.systemTitle,
    this.systemBoardColumnDone,
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

  final MicrosoftVstsCommonPriority? systemId;
  final MicrosoftVstsCommonPriority? systemAreaId;
  final MicrosoftVstsCommonValueArea? systemNodeName;
  final MicrosoftVstsCommonValueArea? systemAreaLevel1;
  final SystemRevClass systemRev;
  final SystemAuthorizedDate systemAuthorizedDate;
  final SystemAuthorizedDate systemRevisedDate;
  final MicrosoftVstsCommonPriority? systemIterationId;
  final MicrosoftVstsCommonValueArea? systemIterationLevel1;
  final MicrosoftVstsCommonValueArea? systemWorkItemType;
  final SystemAuthorizedDate? systemState;
  final SystemAuthorizedDate? systemReason;
  final SystemAssignedToClass? systemAssignedTo;
  final MicrosoftVstsCommonValueArea? systemCreatedDate;
  final SystemAssignedToClass? systemCreatedBy;
  final SystemAuthorizedDate? systemChangedDate;
  final MicrosoftVstsCommonActivatedBy? systemChangedBy;
  final MicrosoftVstsCommonActivatedBy? systemAuthorizedAs;
  final SystemRevClass? systemPersonId;
  final SystemRevClass systemWatermark;
  final SystemBoardColumnDone? systemIsDeleted;
  final SystemRevClass? systemCommentCount;
  final MicrosoftVstsCommonValueArea? systemTeamProject;
  final MicrosoftVstsCommonValueArea? systemAreaPath;
  final MicrosoftVstsCommonValueArea? systemIterationPath;
  final MicrosoftVstsCommonValueArea? systemTitle;
  final SystemBoardColumnDone? systemBoardColumnDone;
  final MicrosoftVstsCommonPriority? microsoftVstsCommonPriority;
  final MicrosoftVstsCommonValueArea? microsoftVstsCommonValueArea;
  final SystemAuthorizedDate? microsoftVstsCommonStateChangeDate;
  final SystemAuthorizedDate? systemHistory;
  final MicrosoftVstsCommonActivatedBy? microsoftVstsCommonActivatedBy;
  final SystemAuthorizedDate? microsoftVstsCommonActivatedDate;
  final SystemAuthorizedDate? microsoftVstsCommonResolvedDate;
  final MicrosoftVstsCommonActivatedBy? microsoftVstsCommonResolvedBy;
  final MicrosoftVstsCommonPriority? microsoftVstsSchedulingEffort;

  @override
  String toString() {
    return 'Fields(systemId: $systemId, systemAreaId: $systemAreaId, systemNodeName: $systemNodeName, systemAreaLevel1: $systemAreaLevel1, systemRev: $systemRev, systemAuthorizedDate: $systemAuthorizedDate, systemRevisedDate: $systemRevisedDate, systemIterationId: $systemIterationId, systemIterationLevel1: $systemIterationLevel1, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemAuthorizedAs: $systemAuthorizedAs, systemPersonId: $systemPersonId, systemWatermark: $systemWatermark, systemIsDeleted: $systemIsDeleted, systemCommentCount: $systemCommentCount, systemTeamProject: $systemTeamProject, systemAreaPath: $systemAreaPath, systemIterationPath: $systemIterationPath, systemTitle: $systemTitle, systemBoardColumnDone: $systemBoardColumnDone, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, microsoftVstsCommonValueArea: $microsoftVstsCommonValueArea, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, systemHistory: $systemHistory, microsoftVstsCommonActivatedBy: $microsoftVstsCommonActivatedBy, microsoftVstsCommonActivatedDate: $microsoftVstsCommonActivatedDate, microsoftVstsCommonResolvedDate: $microsoftVstsCommonResolvedDate, microsoftVstsCommonResolvedBy: $microsoftVstsCommonResolvedBy, microsoftVstsSchedulingEffort: $microsoftVstsSchedulingEffort)';
  }
}

class MicrosoftVstsCommonActivatedBy {
  factory MicrosoftVstsCommonActivatedBy.fromJson(Map<String, dynamic> json) => MicrosoftVstsCommonActivatedBy(
        newValue: json['newValue'] == null ? null : RevisedBy.fromJson(json['newValue'] as Map<String, dynamic>),
        oldValue: json['oldValue'] == null ? null : RevisedBy.fromJson(json['oldValue'] as Map<String, dynamic>),
      );

  MicrosoftVstsCommonActivatedBy({
    this.newValue,
    this.oldValue,
  });

  final RevisedBy? newValue;
  final RevisedBy? oldValue;
}

class RevisedBy {
  factory RevisedBy.fromJson(Map<String, dynamic> json) => RevisedBy(
        displayName: json['displayName'] as String,
        url: json['url'] as String,
        links: Links.fromJson(json['_links'] as Map<String, dynamic>),
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
        name: json['name'] as String?,
      );

  RevisedBy({
    required this.displayName,
    required this.url,
    required this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
    this.name,
  });

  final String displayName;
  final String url;
  final Links links;
  final String id;
  final String uniqueName;
  final String imageUrl;
  final String descriptor;
  final String? name;
}

class Links {
  factory Links.fromJson(Map<String, dynamic> json) => Links(
        avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
      );

  Links({
    required this.avatar,
  });

  final Avatar avatar;
}

class Avatar {
  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        href: json['href'] as String,
      );

  Avatar({
    required this.href,
  });

  final String href;
}

class SystemAuthorizedDate {
  factory SystemAuthorizedDate.fromJson(Map<String, dynamic> json) => SystemAuthorizedDate(
        newValue: json['newValue'] as String?,
        oldValue: json['oldValue'] as String?,
      );

  SystemAuthorizedDate({
    this.newValue,
    this.oldValue,
  });

  final String? newValue;
  final String? oldValue;
}

class MicrosoftVstsCommonPriority {
  factory MicrosoftVstsCommonPriority.fromJson(Map<String, dynamic> json) => MicrosoftVstsCommonPriority(
        oldValue: (json['oldValue'] as num?)?.toDouble(),
        newValue: (json['newValue'] as num?)?.toDouble(),
      );

  MicrosoftVstsCommonPriority({
    required this.oldValue,
    required this.newValue,
  });

  final double? oldValue;
  final double? newValue;
}

class MicrosoftVstsCommonValueArea {
  factory MicrosoftVstsCommonValueArea.fromJson(Map<String, dynamic> json) => MicrosoftVstsCommonValueArea(
        oldValue: json['oldValue'] as String?,
        newValue: json['newValue'] as String?,
      );

  MicrosoftVstsCommonValueArea({
    required this.oldValue,
    required this.newValue,
  });

  final String? oldValue;
  final String? newValue;
}

class SystemAssignedToClass {
  factory SystemAssignedToClass.fromJson(Map<String, dynamic> json) => SystemAssignedToClass(
        oldValue: json['oldValue'] == null ? null : RevisedBy.fromJson(json['oldValue'] as Map<String, dynamic>),
        newValue: json['newValue'] == null ? null : RevisedBy.fromJson(json['newValue'] as Map<String, dynamic>),
      );

  SystemAssignedToClass({
    this.oldValue,
    this.newValue,
  });

  final RevisedBy? oldValue;
  final RevisedBy? newValue;
}

class SystemBoardColumnDone {
  factory SystemBoardColumnDone.fromJson(Map<String, dynamic> json) => SystemBoardColumnDone(
        newValue: json['newValue'] as bool?,
      );

  SystemBoardColumnDone({
    required this.newValue,
  });

  final bool? newValue;
}

class SystemRevClass {
  factory SystemRevClass.fromJson(Map<String, dynamic> json) => SystemRevClass(
        newValue: json['newValue'] as int?,
        oldValue: json['oldValue'] as int?,
      );

  SystemRevClass({
    required this.newValue,
    this.oldValue,
  });

  final int? newValue;
  final int? oldValue;
}
