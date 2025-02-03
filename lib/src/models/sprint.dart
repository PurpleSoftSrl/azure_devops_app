import 'dart:convert';

import 'package:azure_devops/src/models/board.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:http/http.dart';

class SprintsResponse {
  SprintsResponse({
    required this.sprints,
  });

  factory SprintsResponse.fromJson(Map<String, dynamic> json) => SprintsResponse(
        sprints: List<Sprint>.from(
          (json['value'] as List<dynamic>? ?? []).map((x) => Sprint.fromJson(x as Map<String, dynamic>)),
        ),
      );

  static List<Sprint> fromResponse(Response res) =>
      SprintsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).sprints;

  final List<Sprint> sprints;
}

class Sprint {
  Sprint({
    required this.id,
    required this.name,
    required this.path,
    required this.attributes,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) => Sprint(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        path: json['path'] as String? ?? '',
        attributes: SprintAttributes.fromJson(json['attributes'] as Map<String, dynamic>? ?? {}),
      );

  static Sprint fromResponse(Response res) => Sprint.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final String id;
  final String name;
  final String path;
  final SprintAttributes attributes;

  Iterable<BoardColumn>? columns;
}

class SprintAttributes {
  SprintAttributes({
    this.startDate,
    this.finishDate,
    required this.timeFrame,
  });

  factory SprintAttributes.fromJson(Map<String, dynamic> json) => SprintAttributes(
        startDate: json['startDate'] == null ? null : DateTime.tryParse(json['startDate'].toString())?.toLocal(),
        finishDate: json['finishDate'] == null ? null : DateTime.tryParse(json['finishDate'].toString())?.toLocal(),
        timeFrame: json['timeFrame'] as String? ?? '',
      );

  final DateTime? startDate;
  final DateTime? finishDate;
  final String timeFrame;
}

class SprintDetailWithItems {
  SprintDetailWithItems({required this.sprint, required this.items});

  final Sprint sprint;
  final List<WorkItem> items;
}

class SprintItemsResponse {
  SprintItemsResponse({required this.workItemRelations});

  factory SprintItemsResponse.fromJson(Map<String, dynamic> json) => SprintItemsResponse(
        workItemRelations: List<WorkItemRelation>.from(
          (json['workItemRelations'] as List<dynamic>? ?? [])
              .map((x) => WorkItemRelation.fromJson(x as Map<String, dynamic>? ?? {})),
        ),
      );

  static List<WorkItemRelation> fromResponse(Response res) =>
      SprintItemsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).workItemRelations;

  final List<WorkItemRelation> workItemRelations;
}

class WorkItemRelation {
  WorkItemRelation({required this.target});

  factory WorkItemRelation.fromJson(Map<String, dynamic> json) => WorkItemRelation(
        target: Target.fromJson(json['target'] as Map<String, dynamic>? ?? {}),
      );

  final Target target;
}

class Target {
  Target({required this.id});

  factory Target.fromJson(Map<String, dynamic> json) => Target(
        id: json['id'] as int? ?? 0,
      );

  final int id;
}

class SprintStatesResponse {
  SprintStatesResponse({required this.fps});

  factory SprintStatesResponse.fromJson(Map<String, dynamic> json) => SprintStatesResponse(
        fps: Fps.fromJson(json['fps'] as Map<String, dynamic>? ?? {}),
      );

  static List<String> fromResponse(Response res) =>
      SprintStatesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>)
          .fps
          .dataProviders
          .data
          .taskboardData
          .taskboardModel
          .states;

  final Fps fps;
}

class Fps {
  Fps({required this.dataProviders});

  factory Fps.fromJson(Map<String, dynamic> json) => Fps(
        dataProviders: DataProviders.fromJson(json['dataProviders'] as Map<String, dynamic>? ?? {}),
      );

  final DataProviders dataProviders;
}

class DataProviders {
  DataProviders({required this.data});

  factory DataProviders.fromJson(Map<String, dynamic> json) => DataProviders(
        data: DataProvidersData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
      );

  final DataProvidersData data;
}

class DataProvidersData {
  DataProvidersData({required this.taskboardData});

  factory DataProvidersData.fromJson(Map<String, dynamic> json) => DataProvidersData(
        taskboardData: MsVssWorkWebNewSprintsHubTaskboardDataProvider.fromJson(
          json['ms.vss-work-web.new-sprints-hub-taskboard-data-provider'] as Map<String, dynamic>? ?? {},
        ),
      );

  final MsVssWorkWebNewSprintsHubTaskboardDataProvider taskboardData;
}

class MsVssWorkWebNewSprintsHubTaskboardDataProvider {
  MsVssWorkWebNewSprintsHubTaskboardDataProvider({required this.taskboardModel});

  factory MsVssWorkWebNewSprintsHubTaskboardDataProvider.fromJson(Map<String, dynamic> json) =>
      MsVssWorkWebNewSprintsHubTaskboardDataProvider(
        taskboardModel: TaskboardModel.fromJson(json['taskboardModel'] as Map<String, dynamic>? ?? {}),
      );

  final TaskboardModel taskboardModel;
}

class TaskboardModel {
  TaskboardModel({
    required this.states,
  });

  factory TaskboardModel.fromJson(Map<String, dynamic> json) => TaskboardModel(
        states: List<String>.from(json['states'] as List<dynamic>? ?? []),
      );

  final List<String> states;
}
