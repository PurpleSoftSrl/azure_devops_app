class WorkItemDetail {
  factory WorkItemDetail.fromJson(Map<String, dynamic> json) => WorkItemDetail(
        id: json['id'] as int,
        rev: json['rev'] as int,
        fields: WorkItemDetailFields.fromJson(json['fields'] as Map<String, dynamic>),
        url: json['url'] as String,
      );

  WorkItemDetail({
    required this.id,
    required this.rev,
    required this.fields,
    required this.url,
  });

  final int id;
  final int rev;
  final WorkItemDetailFields fields;
  final String url;

  @override
  String toString() {
    return 'GetWorkItemDetailResponse(id: $id, rev: $rev, fields: $fields, url: $url)';
  }
}

class WorkItemDetailFields {
  factory WorkItemDetailFields.fromJson(Map<String, dynamic> json) => WorkItemDetailFields(
        systemTeamProject: json['System.TeamProject'] as String,
        systemWorkItemType: json['System.WorkItemType'] as String,
        systemState: json['System.State'] as String,
        systemReason: json['System.Reason'] as String,
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : WorkItemUser.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: DateTime.parse(json['System.CreatedDate']!.toString()).toLocal(),
        systemCreatedBy: WorkItemUser.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: DateTime.parse(json['System.ChangedDate']!.toString()).toLocal(),
        systemChangedBy: WorkItemUser.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] as int,
        systemTitle: json['System.Title'] as String,
        microsoftVstsCommonStateChangeDate: json['Microsoft.VSTS.Common.StateChangeDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.StateChangeDate'].toString()).toLocal(),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] as int?,
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] as String?,
        systemDescription: json['System.Description'] as String?,
        reproSteps: json['Microsoft.VSTS.TCM.ReproSteps'] as String?,
      );

  WorkItemDetailFields({
    required this.systemTeamProject,
    required this.systemWorkItemType,
    required this.systemState,
    required this.systemReason,
    this.systemAssignedTo,
    required this.systemCreatedDate,
    required this.systemCreatedBy,
    required this.systemChangedDate,
    required this.systemChangedBy,
    required this.systemCommentCount,
    required this.systemTitle,
    required this.microsoftVstsCommonStateChangeDate,
    this.microsoftVstsCommonPriority,
    this.microsoftVstsCommonValueArea,
    this.systemDescription,
    this.reproSteps,
  });

  final String systemTeamProject;
  final String systemWorkItemType;
  final String systemState;
  final String systemReason;
  final WorkItemUser? systemAssignedTo;
  final DateTime systemCreatedDate;
  final WorkItemUser systemCreatedBy;
  final DateTime systemChangedDate;
  final WorkItemUser systemChangedBy;
  final int systemCommentCount;
  final String systemTitle;
  final DateTime? microsoftVstsCommonStateChangeDate;
  final int? microsoftVstsCommonPriority;
  final String? microsoftVstsCommonValueArea;
  final String? systemDescription;
  final String? reproSteps;

  @override
  String toString() {
    return 'GetWorkItemDetailResponseFields(systemTeamProject: $systemTeamProject, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemCommentCount: $systemCommentCount, systemTitle: $systemTitle, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, microsoftVstsCommonValueArea: $microsoftVstsCommonValueArea, systemDescription: $systemDescription)';
  }
}

class WorkItemUser {
  factory WorkItemUser.fromJson(Map<String, dynamic> json) => WorkItemUser(
        displayName: json['displayName'] as String,
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
      );

  WorkItemUser({
    required this.displayName,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
  });

  final String displayName;
  final String id;
  final String uniqueName;
  final String imageUrl;
  final String descriptor;

  @override
  String toString() {
    return 'System(displayName: $displayName, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl, descriptor: $descriptor)';
  }
}
