import 'dart:convert';

class WorkItemDetail {
  factory WorkItemDetail.fromJson(Map<String, dynamic> json) => WorkItemDetail(
        id: json['id'] as int,
        rev: json['rev'] as int,
        fields: _GetWorkItemDetailResponseFields.fromJson(json['fields'] as Map<String, dynamic>),
        links: _GetWorkItemDetailResponseLinks.fromJson(json['_links'] as Map<String, dynamic>),
        url: json['url'] as String,
      );
  WorkItemDetail({
    required this.id,
    required this.rev,
    required this.fields,
    required this.links,
    required this.url,
  });

  final int id;
  final int rev;
  final _GetWorkItemDetailResponseFields fields;
  final _GetWorkItemDetailResponseLinks links;
  final String url;

  @override
  String toString() {
    return 'GetWorkItemDetailResponse(id: $id, rev: $rev, fields: $fields, links: $links, url: $url)';
  }
}

class _GetWorkItemDetailResponseFields {
  factory _GetWorkItemDetailResponseFields.fromJson(Map<String, dynamic> json) => _GetWorkItemDetailResponseFields(
        systemAreaPath: json['System.AreaPath'] as String,
        systemTeamProject: json['System.TeamProject'] as String,
        systemIterationPath: json['System.IterationPath'] as String,
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
        systemBoardColumn: json['System.BoardColumn'] as String?,
        systemBoardColumnDone: (json['System.BoardColumnDone'] as bool?) ?? false,
        microsoftVstsCommonStateChangeDate:
            DateTime.tryParse(json['Microsoft.VSTS.Common.StateChangeDate']?.toString() ?? '')?.toLocal(),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] as int?,
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] as String?,
        systemDescription: json['System.Description'] as String?,
        reproSteps: json['Microsoft.VSTS.TCM.ReproSteps'] as String?,
      );

  _GetWorkItemDetailResponseFields({
    required this.systemAreaPath,
    required this.systemTeamProject,
    required this.systemIterationPath,
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
    required this.systemBoardColumn,
    required this.systemBoardColumnDone,
    required this.microsoftVstsCommonStateChangeDate,
    required this.microsoftVstsCommonPriority,
    required this.microsoftVstsCommonValueArea,
    required this.systemDescription,
    required this.reproSteps,
  });

  final String systemAreaPath;
  final String systemTeamProject;
  final String systemIterationPath;
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
  final String? systemBoardColumn;
  final bool systemBoardColumnDone;
  final DateTime? microsoftVstsCommonStateChangeDate;
  final int? microsoftVstsCommonPriority;
  final String? microsoftVstsCommonValueArea;
  final String? systemDescription;
  final String? reproSteps;

  @override
  String toString() {
    return 'GetWorkItemDetailResponseFields(systemAreaPath: $systemAreaPath, systemTeamProject: $systemTeamProject, systemIterationPath: $systemIterationPath, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemCommentCount: $systemCommentCount, systemTitle: $systemTitle, systemBoardColumn: $systemBoardColumn, systemBoardColumnDone: $systemBoardColumnDone, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, microsoftVstsCommonValueArea: $microsoftVstsCommonValueArea, systemDescription: $systemDescription)';
  }
}

class _System {
  factory _System.fromJson(Map<String, dynamic> json) => _System(
        displayName: json['displayName'] as String,
        url: json['url'] as String?,
        links: json['_links'] == null ? null : _SystemAssignedToLinks.fromJson(json['_links'] as Map<String, dynamic>),
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
      );

  _System({
    required this.displayName,
    required this.url,
    required this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
  });

  final String displayName;
  final String? url;
  final _SystemAssignedToLinks? links;
  final String id;
  final String uniqueName;
  final String imageUrl;
  final String descriptor;

  @override
  String toString() {
    return 'System(displayName: $displayName, url: $url, links: $links, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl, descriptor: $descriptor)';
  }
}

class _SystemAssignedToLinks {
  factory _SystemAssignedToLinks.fromJson(Map<String, dynamic> json) => _SystemAssignedToLinks(
        avatar: _HtmlClass.fromJson(json['avatar'] as Map<String, dynamic>),
      );

  _SystemAssignedToLinks({required this.avatar});

  final _HtmlClass avatar;
}

class _HtmlClass {
  factory _HtmlClass.fromJson(Map<String, dynamic> json) => _HtmlClass(
        href: json['href'] as String,
      );

  _HtmlClass({required this.href});

  final String href;
}

class _GetWorkItemDetailResponseLinks {
  factory _GetWorkItemDetailResponseLinks.fromJson(Map<String, dynamic> json) => _GetWorkItemDetailResponseLinks(
        self: _HtmlClass.fromJson(json['self'] as Map<String, dynamic>),
        workItemUpdates: _HtmlClass.fromJson(json['workItemUpdates'] as Map<String, dynamic>),
        workItemRevisions: _HtmlClass.fromJson(json['workItemRevisions'] as Map<String, dynamic>),
        workItemComments: _HtmlClass.fromJson(json['workItemComments'] as Map<String, dynamic>),
        html: _HtmlClass.fromJson(json['html'] as Map<String, dynamic>),
        workItemType: _HtmlClass.fromJson(json['workItemType'] as Map<String, dynamic>),
        fields: _HtmlClass.fromJson(json['fields'] as Map<String, dynamic>),
      );

  _GetWorkItemDetailResponseLinks({
    required this.self,
    required this.workItemUpdates,
    required this.workItemRevisions,
    required this.workItemComments,
    required this.html,
    required this.workItemType,
    required this.fields,
  });

  final _HtmlClass self;
  final _HtmlClass workItemUpdates;
  final _HtmlClass workItemRevisions;
  final _HtmlClass workItemComments;
  final _HtmlClass html;
  final _HtmlClass workItemType;
  final _HtmlClass fields;
}

class GetWorkItemStatusesResponse {
  GetWorkItemStatusesResponse({
    required this.count,
    required this.statuses,
  });

  factory GetWorkItemStatusesResponse.fromRawJson(String str) =>
      GetWorkItemStatusesResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  factory GetWorkItemStatusesResponse.fromJson(Map<String, dynamic> json) => GetWorkItemStatusesResponse(
        count: json['count'] as int,
        statuses: List<WorkItemStatus>.from(
          (json['value'] as List<dynamic>).map((x) => WorkItemStatus.fromJson(x as Map<String, dynamic>)),
        ),
      );

  final int count;
  final List<WorkItemStatus> statuses;
}

class WorkItemStatus {
  WorkItemStatus({
    required this.name,
    required this.color,
    required this.category,
  });

  factory WorkItemStatus.fromRawJson(String str) => WorkItemStatus.fromJson(json.decode(str) as Map<String, dynamic>);

  factory WorkItemStatus.fromJson(Map<String, dynamic> json) => WorkItemStatus(
        name: json['name'] as String,
        color: json['color'] as String,
        category: json['category'] as String,
      );

  final String name;
  final String color;
  final String category;
}
