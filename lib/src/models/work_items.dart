class GetWorkItemIds {
  GetWorkItemIds({
    required this.workItems,
  });

  factory GetWorkItemIds.fromJson(Map<String, dynamic> json) => GetWorkItemIds(
        workItems: List<WorkItemId>.from(
          (json['workItems'] as List<dynamic>).map(
            (w) => WorkItemId.fromJson(w as Map<String, dynamic>),
          ),
        ),
      );

  final List<WorkItemId> workItems;
}

class WorkItemId {
  WorkItemId({
    required this.id,
    required this.url,
  });

  factory WorkItemId.fromJson(Map<String, dynamic> json) => WorkItemId(
        id: json['id'] as int,
        url: json['url'] as String,
      );

  final int id;
  final String url;
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

  final int count;
  final List<WorkItem> items;
}

class WorkItem {
  WorkItem({
    required this.id,
    this.rev,
    required this.fields,
    this.url,
    this.commentVersionRef,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) => WorkItem(
        id: json['id'] as int,
        rev: json['rev'] as int?,
        fields: ItemFields.fromJson(json['fields'] as Map<String, dynamic>),
        url: json['url'] as String?,
        commentVersionRef: json['commentVersionRef'] == null
            ? null
            : CommentVersionRef.fromJson(json['commentVersionRef'] as Map<String, dynamic>),
      );

  final int id;
  final int? rev;
  final ItemFields fields;
  final String? url;
  final CommentVersionRef? commentVersionRef;
}

class CommentVersionRef {
  CommentVersionRef({
    required this.commentId,
    required this.version,
    required this.url,
  });

  factory CommentVersionRef.fromJson(Map<String, dynamic> json) => CommentVersionRef(
        commentId: json['commentId'] as int,
        version: json['version'] as int,
        url: json['url'] as String,
      );

  final int commentId;
  final int version;
  final String url;
}

class ItemFields {
  ItemFields({
    this.systemAreaPath,
    required this.systemTeamProject,
    this.systemIterationPath,
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
    this.microsoftVstsCommonClosedDate,
    this.microsoftVstsCommonClosedBy,
    this.microsoftVstsCommonActivatedDate,
    this.microsoftVstsCommonActivatedBy,
    this.microsoftVstsCommonResolvedDate,
    this.systemHistory,
    this.systemTags,
  });

  factory ItemFields.fromJson(Map<String, dynamic> json) => ItemFields(
        systemAreaPath: json['System.AreaPath'] as String?,
        systemTeamProject: json['System.TeamProject'] as String,
        systemIterationPath: json['System.IterationPath'] as String?,
        systemWorkItemType: json['System.WorkItemType'] as String,
        systemState: json['System.State'] as String,
        systemReason: json['System.Reason'] as String?,
        systemAssignedTo: json['System.AssignedTo'] == null
            ? null
            : SystemChangedBy.fromJson(json['System.AssignedTo'] as Map<String, dynamic>),
        systemCreatedDate: DateTime.parse(json['System.CreatedDate']!.toString()).toLocal(),
        systemCreatedBy: SystemChangedBy.fromJson(json['System.CreatedBy'] as Map<String, dynamic>),
        systemChangedDate: DateTime.parse(json['System.ChangedDate']!.toString()).toLocal(),
        systemChangedBy: json['System.ChangedBy'] == null
            ? null
            : SystemChangedBy.fromJson(json['System.ChangedBy'] as Map<String, dynamic>),
        systemCommentCount: json['System.CommentCount'] as int,
        systemTitle: json['System.Title'] as String,
        microsoftVstsCommonStateChangeDate:
            DateTime.parse(json['Microsoft.VSTS.Common.StateChangeDate']!.toString()).toLocal(),
        microsoftVstsCommonPriority: json['Microsoft.VSTS.Common.Priority'] as int,
        systemDescription: json['System.Description'] as String?,
        microsoftVstsCommonClosedDate: json['Microsoft.VSTS.Common.ClosedDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.ClosedDate']!.toString()).toLocal(),
        microsoftVstsCommonClosedBy: json['Microsoft.VSTS.Common.ClosedBy'] == null
            ? null
            : SystemChangedBy.fromJson(json['Microsoft.VSTS.Common.ClosedBy'] as Map<String, dynamic>),
        microsoftVstsCommonActivatedDate: json['Microsoft.VSTS.Common.ActivatedDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.ActivatedDate']!.toString()).toLocal(),
        microsoftVstsCommonActivatedBy: json['Microsoft.VSTS.Common.ActivatedBy'] == null
            ? null
            : SystemChangedBy.fromJson(json['Microsoft.VSTS.Common.ActivatedBy'] as Map<String, dynamic>),
        microsoftVstsCommonResolvedDate: json['Microsoft.VSTS.Common.ResolvedDate'] == null
            ? null
            : DateTime.parse(json['Microsoft.VSTS.Common.ResolvedDate']!.toString()).toLocal(),
        systemHistory: json['System.History'] as String?,
        systemTags: json['System.Tags'] as String?,
      );

  final String? systemAreaPath;
  final String systemTeamProject;
  final String? systemIterationPath;
  final String systemWorkItemType;
  final String systemState;
  final String? systemReason;
  final SystemChangedBy? systemAssignedTo;
  final DateTime? systemCreatedDate;
  final SystemChangedBy? systemCreatedBy;
  final DateTime systemChangedDate;
  final SystemChangedBy? systemChangedBy;
  final int? systemCommentCount;
  final String systemTitle;
  final DateTime? microsoftVstsCommonStateChangeDate;
  final int? microsoftVstsCommonPriority;
  final String? systemDescription;
  final DateTime? microsoftVstsCommonClosedDate;
  final SystemChangedBy? microsoftVstsCommonClosedBy;
  final DateTime? microsoftVstsCommonActivatedDate;
  final SystemChangedBy? microsoftVstsCommonActivatedBy;
  final DateTime? microsoftVstsCommonResolvedDate;
  final String? systemHistory;
  final String? systemTags;
}

class SystemChangedBy {
  SystemChangedBy({
    required this.displayName,
    required this.url,
    required this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
    this.inactive,
  });

  factory SystemChangedBy.fromJson(Map<String, dynamic> json) => SystemChangedBy(
        displayName: json['displayName'] as String,
        url: json['url'] as String,
        links: Links.fromJson(json['_links'] as Map<String, dynamic>),
        id: json['id'] as String,
        uniqueName: json['uniqueName'] as String,
        imageUrl: json['imageUrl'] as String,
        descriptor: json['descriptor'] as String,
        inactive: json['inactive'] as bool?,
      );

  final String displayName;
  final String url;
  final Links links;
  final String id;
  final String uniqueName;
  final String imageUrl;
  final String descriptor;
  final bool? inactive;
}

class Links {
  Links({required this.avatar});

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
      );

  final Avatar avatar;
}

class Avatar {
  Avatar({
    required this.href,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(href: json['href'] as String);
  final String href;
}
