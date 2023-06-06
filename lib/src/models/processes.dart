import 'dart:convert';

import 'package:azure_devops/src/models/project.dart';
import 'package:http/http.dart';

class GetProcessesResponse {
  GetProcessesResponse({
    required this.count,
    required this.processes,
  });

  factory GetProcessesResponse.fromJson(Map<String, dynamic> json) => GetProcessesResponse(
        count: json['count'] as int,
        processes: List<WorkProcess>.from(
          (json['value'] as List<dynamic>).map((p) => WorkProcess.fromJson(p as Map<String, dynamic>)),
        ),
      );

  static List<WorkProcess> fromResponse(Response res) =>
      GetProcessesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).processes;

  final int count;
  final List<WorkProcess> processes;
}

class WorkProcess {
  WorkProcess({
    required this.typeId,
    required this.name,
    this.referenceName,
    required this.description,
    required this.parentProcessTypeId,
    required this.isEnabled,
    required this.isDefault,
    required this.customizationType,
    required this.projects,
  });

  factory WorkProcess.fromJson(Map<String, dynamic> json) => WorkProcess(
        typeId: json['typeId'] as String,
        name: json['name'] as String,
        referenceName: json['referenceName'] as String?,
        description: json['description'] as String,
        parentProcessTypeId: json['parentProcessTypeId'] as String,
        isEnabled: json['isEnabled'] as bool,
        isDefault: json['isDefault'] as bool,
        customizationType: json['customizationType'] as String,
        projects:
            (json['projects'] as List<dynamic>? ?? []).map((e) => Project.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final String typeId;
  final String name;
  final String? referenceName;
  final String description;
  final String parentProcessTypeId;
  final bool isEnabled;
  final bool isDefault;
  final String customizationType;
  final List<Project> projects;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkProcess && other.typeId == typeId;
  }

  @override
  int get hashCode {
    return typeId.hashCode;
  }
}

class GetWorkItemTypesResponse {
  GetWorkItemTypesResponse({
    required this.count,
    required this.types,
  });

  factory GetWorkItemTypesResponse.fromJson(Map<String, dynamic> json) => GetWorkItemTypesResponse(
        count: json['count'] as int,
        types: List<WorkItemType>.from(
          (json['value'] as List<dynamic>).map((t) => WorkItemType.fromJson(t as Map<String, dynamic>)),
        ),
      );

  static List<WorkItemType> fromResponse(Response res) =>
      GetWorkItemTypesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).types;

  final int count;
  final List<WorkItemType> types;
}

class WorkItemType {
  WorkItemType({
    required this.referenceName,
    required this.name,
    required this.description,
    required this.url,
    required this.customization,
    required this.color,
    required this.icon,
    required this.isDisabled,
  });

  factory WorkItemType.fromJson(Map<String, dynamic> json) => WorkItemType(
        referenceName: json['referenceName'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        url: json['url'] as String,
        customization: json['customization'] as String,
        color: json['color'] as String,
        icon: json['icon'] as String,
        isDisabled: json['isDisabled'] as bool,
      );

  static WorkItemType get all {
    return WorkItemType(
      name: 'All',
      referenceName: 'All',
      description: 'All types',
      color: '',
      isDisabled: false,
      customization: '',
      icon: '',
      url: '',
    );
  }

  final String referenceName;
  final String name;
  final String description;
  final String url;
  final String customization;
  final String color;
  final String icon;
  final bool isDisabled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkItemType && other.referenceName == referenceName;
  }

  @override
  int get hashCode {
    return referenceName.hashCode;
  }
}

class GetWorkItemStatesResponse {
  GetWorkItemStatesResponse({
    required this.count,
    required this.states,
  });

  factory GetWorkItemStatesResponse.fromJson(Map<String, dynamic> json) => GetWorkItemStatesResponse(
        count: json['count'] as int,
        states: List<WorkItemState>.from(
          (json['value'] as List<dynamic>).map((s) => WorkItemState.fromJson(s as Map<String, dynamic>)),
        ),
      );

  static List<WorkItemState> fromResponse(Response res) =>
      GetWorkItemStatesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).states;

  final int count;
  final List<WorkItemState> states;
}

class WorkItemState {
  WorkItemState({
    required this.id,
    required this.name,
    required this.color,
    required this.stateCategory,
    required this.order,
    required this.url,
    required this.customizationType,
  });

  factory WorkItemState.fromJson(Map<String, dynamic> json) => WorkItemState(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as String,
        stateCategory: json['stateCategory'] as String,
        order: json['order'] as int,
        url: json['url'] as String,
        customizationType: json['customizationType'] as String,
      );

  static WorkItemState get all {
    return WorkItemState(
      name: 'All',
      color: '',
      url: '',
      customizationType: '',
      id: '',
      order: 0,
      stateCategory: '',
    );
  }

  final String id;
  final String name;
  final String color;
  final String stateCategory;
  final int order;
  final String url;
  final String customizationType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkItemState && other.name == name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }
}
