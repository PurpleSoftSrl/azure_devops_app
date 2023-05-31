class WorkItemDetail {
  factory WorkItemDetail.fromJson(Map<String, dynamic> json) => WorkItemDetail(
        id: json['id'] as int,
        rev: json['rev'] as int,
        fields: _GetWorkItemDetailResponseFields.fromJson(json['fields'] as Map<String, dynamic>),
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
  final _GetWorkItemDetailResponseFields fields;
  final String url;

  @override
  String toString() {
    return 'GetWorkItemDetailResponse(id: $id, rev: $rev, fields: $fields, url: $url)';
  }
}

class _GetWorkItemDetailResponseFields {
  factory _GetWorkItemDetailResponseFields.fromJson(Map<String, dynamic> json) => _GetWorkItemDetailResponseFields(
        systemTeamProject: json['System.TeamProject'] as String,
        systemWorkItemType: json['System.WorkItemType'] as String,
        systemState: json['System.State'] as String,
        systemReason: json['System.Reason'] as String,
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : _System.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: DateTime.parse(json['System.CreatedDate']!.toString()).toLocal(),
        systemCreatedBy: _System.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: DateTime.parse(json['System.ChangedDate']!.toString()).toLocal(),
        systemChangedBy: _System.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] as int,
        systemTitle: json['System.Title'] as String,
        microsoftVstsCommonStateChangeDate:
            DateTime.tryParse(json['Microsoft.VSTS.Common.StateChangeDate']?.toString() ?? '')?.toLocal(),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] as int?,
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] as String?,
        systemDescription: json['System.Description'] as String?,
        reproSteps: json['Microsoft.VSTS.TCM.ReproSteps'] as String?,
      );

  _GetWorkItemDetailResponseFields({
    required this.systemTeamProject,
    required this.systemWorkItemType,
    required this.systemState,
    required this.systemReason,
    required this.systemAssignedTo,
    required this.systemCreatedDate,
    required this.systemCreatedBy,
    required this.systemChangedDate,
    required this.systemChangedBy,
    required this.systemCommentCount,
    required this.systemTitle,
    required this.microsoftVstsCommonStateChangeDate,
    required this.microsoftVstsCommonPriority,
    required this.microsoftVstsCommonValueArea,
    required this.systemDescription,
    required this.reproSteps,
  });

  final String systemTeamProject;
  final String systemWorkItemType;
  final String systemState;
  final String systemReason;
  final _System? systemAssignedTo;
  final DateTime systemCreatedDate;
  final _System systemCreatedBy;
  final DateTime systemChangedDate;
  final _System systemChangedBy;
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

class _System {
  factory _System.fromJson(Map<String, dynamic> json) => _System(
        displayName: json['displayName'] as String,
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
      );

  _System({
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
