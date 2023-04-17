import 'dart:convert';

class GetWorkItemsResponse {
  factory GetWorkItemsResponse.fromJson(Map<String, dynamic> json) => GetWorkItemsResponse(
        count: json['count'] as int,
        workItems: List<WorkItem>.from(
          (json['value'] as List<dynamic>).map((e) => WorkItem.fromJson(e as Map<String, dynamic>)),
        ),
      );
  GetWorkItemsResponse({
    required this.count,
    required this.workItems,
  });

  final int count;
  final List<WorkItem> workItems;

  Map<String, dynamic> toJson() => {
        'count': count,
        'value': List<dynamic>.from(workItems.map((x) => x.toJson())),
      };

  @override
  String toString() => 'GetWorkItemsResponse(count: $count, workItems: $workItems)';
}

class WorkItem {
  factory WorkItem.fromJson(Map<String, dynamic> json) => WorkItem(
        assignedTo: json['assignedTo'] != null ? AssignedTo.fromJson(json['assignedTo'] as Map<String, dynamic>) : null,
        id: json['id'] as int,
        workItemType: json['workItemType'] as String,
        title: json['title'] as String,
        state: json['state'] as String,
        changedDate: DateTime.parse(json['changedDate'] as String).toLocal(),
        teamProject: json['teamProject'] as String,
        activityDate: DateTime.parse(json['activityDate'] as String).toLocal(),
        activityType: json['activityType'] as String,
        identityId: json['identityId'] as String,
      );

  WorkItem({
    required this.assignedTo,
    required this.id,
    required this.workItemType,
    required this.title,
    required this.state,
    required this.changedDate,
    required this.teamProject,
    required this.activityDate,
    required this.activityType,
    required this.identityId,
  });

  final AssignedTo? assignedTo;
  final int id;
  final String workItemType;
  final String title;
  final String state;
  final DateTime changedDate;
  final String teamProject;
  final DateTime activityDate;
  final String activityType;
  final String identityId;

  Map<String, dynamic> toJson() => {
        'assignedTo': assignedTo?.toJson(),
        'id': id,
        'workItemType': workItemType,
        'title': title,
        'state': state,
        'changedDate': changedDate.toIso8601String(),
        'teamProject': teamProject,
        'activityDate': activityDate.toIso8601String(),
        'activityType': activityType,
        'identityId': identityId,
      };

  @override
  String toString() {
    return 'WorkItem(assignedTo: $assignedTo, id: $id, workItemType: $workItemType, title: $title, state: $state, changedDate: $changedDate, teamProject: $teamProject, activityDate: $activityDate, activityType: $activityType, identityId: $identityId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkItem &&
        other.assignedTo == assignedTo &&
        other.id == id &&
        other.workItemType == workItemType &&
        other.title == title &&
        other.state == state &&
        other.changedDate == changedDate &&
        other.teamProject == teamProject &&
        other.activityDate == activityDate &&
        other.activityType == activityType &&
        other.identityId == identityId;
  }

  @override
  int get hashCode {
    return assignedTo.hashCode ^
        id.hashCode ^
        workItemType.hashCode ^
        title.hashCode ^
        state.hashCode ^
        changedDate.hashCode ^
        teamProject.hashCode ^
        activityDate.hashCode ^
        activityType.hashCode ^
        identityId.hashCode;
  }
}

class AssignedTo {
  factory AssignedTo.fromJson(Map<String, dynamic> json) => AssignedTo(
        id: json['id'] as String?,
        name: json['name'] as String,
        displayName: json['displayName'] as String,
        uniqueName: json['uniqueName'] as String?,
        descriptor: json['descriptor'] as String?,
      );
  AssignedTo({
    required this.id,
    required this.name,
    required this.displayName,
    required this.uniqueName,
    required this.descriptor,
  });

  final String? id;
  final String name;
  final String displayName;
  final String? uniqueName;
  final String? descriptor;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'displayName': displayName,
        'uniqueName': uniqueName,
        'descriptor': descriptor,
      };

  @override
  String toString() {
    return 'AssignedTo(id: $id, name: $name, displayName: $displayName, uniqueName: $uniqueName, descriptor: $descriptor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignedTo &&
        other.id == id &&
        other.name == name &&
        other.displayName == displayName &&
        other.uniqueName == uniqueName &&
        other.descriptor == descriptor;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ displayName.hashCode ^ uniqueName.hashCode ^ descriptor.hashCode;
  }
}

class WorkItemDetail {
  factory WorkItemDetail.fromJson(Map<String, dynamic> json) => WorkItemDetail(
        id: json['id'] as int,
        rev: json['rev'] as int,
        fields: GetWorkItemDetailResponseFields.fromJson(json['fields'] as Map<String, dynamic>),
        links: GetWorkItemDetailResponseLinks.fromJson(json['_links'] as Map<String, dynamic>),
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
  final GetWorkItemDetailResponseFields fields;
  final GetWorkItemDetailResponseLinks links;
  final String url;

  Map<String, dynamic> toJson() => {
        'id': id,
        'rev': rev,
        'fields': fields.toJson(),
        '_links': links.toJson(),
        'url': url,
      };

  @override
  String toString() {
    return 'GetWorkItemDetailResponse(id: $id, rev: $rev, fields: $fields, links: $links, url: $url)';
  }
}

class GetWorkItemDetailResponseFields {
  factory GetWorkItemDetailResponseFields.fromJson(Map<String, dynamic> json) => GetWorkItemDetailResponseFields(
        systemAreaPath: json['System.AreaPath'] as String,
        systemTeamProject: json['System.TeamProject'] as String,
        systemIterationPath: json['System.IterationPath'] as String,
        systemWorkItemType: json['System.WorkItemType'] as String,
        systemState: json['System.State'] as String,
        systemReason: json['System.Reason'] as String,
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : System.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: DateTime.parse(json['System.CreatedDate']!.toString()).toLocal(),
        systemCreatedBy: System.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: DateTime.parse(json['System.ChangedDate']!.toString()).toLocal(),
        systemChangedBy: System.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] as int,
        systemTitle: json['System.Title'] as String,
        systemBoardColumn: json['System.BoardColumn'] as String?,
        systemBoardColumnDone: (json['System.BoardColumnDone'] as bool?) ?? false,
        microsoftVstsCommonStateChangeDate:
            DateTime.tryParse(json['Microsoft.VSTS.Common.StateChangeDate']?.toString() ?? '')?.toLocal(),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] as int?,
        microsoftVstsCommonValueArea: json['Microsoft.VSTS.Common.ValueArea'] as String?,
        systemDescription: json['System.Description'] as String?,
      );

  GetWorkItemDetailResponseFields({
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
  });

  final String systemAreaPath;
  final String systemTeamProject;
  final String systemIterationPath;
  final String systemWorkItemType;
  final String systemState;
  final String systemReason;
  final System? systemAssignedTo;
  final DateTime systemCreatedDate;
  final System systemCreatedBy;
  final DateTime systemChangedDate;
  final System systemChangedBy;
  final int systemCommentCount;
  final String systemTitle;
  final String? systemBoardColumn;
  final bool systemBoardColumnDone;
  final DateTime? microsoftVstsCommonStateChangeDate;
  final int? microsoftVstsCommonPriority;
  final String? microsoftVstsCommonValueArea;
  final String? systemDescription;

  Map<String, dynamic> toJson() => {
        'System.AreaPath': systemAreaPath,
        'System.TeamProject': systemTeamProject,
        'System.IterationPath': systemIterationPath,
        'System.WorkItemType': systemWorkItemType,
        'System.State': systemState,
        'System.Reason': systemReason,
        'System.AssignedTo': systemAssignedTo?.toJson(),
        'System.CreatedDate': systemCreatedDate.toIso8601String(),
        'System.CreatedBy': systemCreatedBy.toJson(),
        'System.ChangedDate': systemChangedDate.toIso8601String(),
        'System.ChangedBy': systemChangedBy.toJson(),
        'System.CommentCount': systemCommentCount,
        'System.Title': systemTitle,
        'System.BoardColumn': systemBoardColumn,
        'System.BoardColumnDone': systemBoardColumnDone,
        'Microsoft.VSTS.Common.StateChangeDate': microsoftVstsCommonStateChangeDate?.toIso8601String(),
        'Microsoft.VSTS.Common.Priority': microsoftVstsCommonPriority,
        'Microsoft.VSTS.Common.ValueArea': microsoftVstsCommonValueArea,
        'System.Description': systemDescription,
      };

  @override
  String toString() {
    return 'GetWorkItemDetailResponseFields(systemAreaPath: $systemAreaPath, systemTeamProject: $systemTeamProject, systemIterationPath: $systemIterationPath, systemWorkItemType: $systemWorkItemType, systemState: $systemState, systemReason: $systemReason, systemAssignedTo: $systemAssignedTo, systemCreatedDate: $systemCreatedDate, systemCreatedBy: $systemCreatedBy, systemChangedDate: $systemChangedDate, systemChangedBy: $systemChangedBy, systemCommentCount: $systemCommentCount, systemTitle: $systemTitle, systemBoardColumn: $systemBoardColumn, systemBoardColumnDone: $systemBoardColumnDone, microsoftVstsCommonStateChangeDate: $microsoftVstsCommonStateChangeDate, microsoftVstsCommonPriority: $microsoftVstsCommonPriority, microsoftVstsCommonValueArea: $microsoftVstsCommonValueArea, systemDescription: $systemDescription)';
  }
}

class System {
  factory System.fromJson(Map<String, dynamic> json) => System(
        displayName: json['displayName'] as String,
        url: json['url'] as String?,
        links: SystemAssignedToLinks.fromJson(json['_links'] as Map<String, dynamic>),
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
      );

  System({
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
  final SystemAssignedToLinks links;
  final String id;
  final String uniqueName;
  final String imageUrl;
  final String descriptor;

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'url': url,
        '_links': links.toJson(),
        'id': id,
        'uniqueName': uniqueName,
        'imageUrl': imageUrl,
        'descriptor': descriptor,
      };

  @override
  String toString() {
    return 'System(displayName: $displayName, url: $url, links: $links, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl, descriptor: $descriptor)';
  }
}

class SystemAssignedToLinks {
  factory SystemAssignedToLinks.fromJson(Map<String, dynamic> json) => SystemAssignedToLinks(
        avatar: HtmlClass.fromJson(json['avatar'] as Map<String, dynamic>),
      );

  SystemAssignedToLinks({
    required this.avatar,
  });

  final HtmlClass avatar;

  Map<String, dynamic> toJson() => {
        'avatar': avatar.toJson(),
      };
}

class HtmlClass {
  factory HtmlClass.fromJson(Map<String, dynamic> json) => HtmlClass(
        href: json['href'] as String,
      );

  HtmlClass({
    required this.href,
  });

  final String href;

  Map<String, dynamic> toJson() => {
        'href': href,
      };
}

class GetWorkItemDetailResponseLinks {
  factory GetWorkItemDetailResponseLinks.fromJson(Map<String, dynamic> json) => GetWorkItemDetailResponseLinks(
        self: HtmlClass.fromJson(json['self'] as Map<String, dynamic>),
        workItemUpdates: HtmlClass.fromJson(json['workItemUpdates'] as Map<String, dynamic>),
        workItemRevisions: HtmlClass.fromJson(json['workItemRevisions'] as Map<String, dynamic>),
        workItemComments: HtmlClass.fromJson(json['workItemComments'] as Map<String, dynamic>),
        html: HtmlClass.fromJson(json['html'] as Map<String, dynamic>),
        workItemType: HtmlClass.fromJson(json['workItemType'] as Map<String, dynamic>),
        fields: HtmlClass.fromJson(json['fields'] as Map<String, dynamic>),
      );

  GetWorkItemDetailResponseLinks({
    required this.self,
    required this.workItemUpdates,
    required this.workItemRevisions,
    required this.workItemComments,
    required this.html,
    required this.workItemType,
    required this.fields,
  });

  final HtmlClass self;
  final HtmlClass workItemUpdates;
  final HtmlClass workItemRevisions;
  final HtmlClass workItemComments;
  final HtmlClass html;
  final HtmlClass workItemType;
  final HtmlClass fields;

  Map<String, dynamic> toJson() => {
        'self': self.toJson(),
        'workItemUpdates': workItemUpdates.toJson(),
        'workItemRevisions': workItemRevisions.toJson(),
        'workItemComments': workItemComments.toJson(),
        'html': html.toJson(),
        'workItemType': workItemType.toJson(),
        'fields': fields.toJson(),
      };
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

  Map<String, dynamic> toJson() => {
        'count': count,
        'value': List<dynamic>.from(statuses.map((x) => x.toJson())),
      };
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

  String toRawJson() => json.encode(toJson());

  final String name;
  final String color;
  final String category;

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
        'category': category,
      };
}
