import 'dart:convert';

import 'package:azure_devops/src/models/board.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:http/http.dart';

class SprintsResponse {
  SprintsResponse({required this.sprints});

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
  Sprint({required this.id, required this.name, required this.path, required this.attributes});

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

  List<BoardColumn>? columns;
  String? teamDefaultArea;
  List<String>? types;
}

class SprintAttributes {
  SprintAttributes({this.startDate, this.finishDate, required this.timeFrame});

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
    workItemRelations: List<_WorkItemRelation>.from(
      (json['workItemRelations'] as List<dynamic>? ?? []).map(
        (x) => _WorkItemRelation.fromJson(x as Map<String, dynamic>? ?? {}),
      ),
    ),
  );

  static List<_WorkItemRelation> fromResponse(Response res) =>
      SprintItemsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).workItemRelations;

  final List<_WorkItemRelation> workItemRelations;
}

class _WorkItemRelation {
  _WorkItemRelation({required this.target});

  factory _WorkItemRelation.fromJson(Map<String, dynamic> json) =>
      _WorkItemRelation(target: _Target.fromJson(json['target'] as Map<String, dynamic>? ?? {}));

  final _Target target;
}

class _Target {
  _Target({required this.id});

  factory _Target.fromJson(Map<String, dynamic> json) => _Target(id: json['id'] as int? ?? 0);

  final int id;
}

class SprintDetailResponse {
  SprintDetailResponse({required this.fps});

  factory SprintDetailResponse.fromJson(Map<String, dynamic> json) =>
      SprintDetailResponse(fps: _Fps.fromJson(json['fps'] as Map<String, dynamic>? ?? {}));

  static _TaskboardModel fromResponse(Response res) => SprintDetailResponse.fromJson(
    jsonDecode(res.body) as Map<String, dynamic>,
  ).fps.dataProviders.data.taskboardData.taskboardModel;

  final _Fps fps;
}

class _Fps {
  _Fps({required this.dataProviders});

  factory _Fps.fromJson(Map<String, dynamic> json) =>
      _Fps(dataProviders: _DataProviders.fromJson(json['dataProviders'] as Map<String, dynamic>? ?? {}));

  final _DataProviders dataProviders;
}

class _DataProviders {
  _DataProviders({required this.data});

  factory _DataProviders.fromJson(Map<String, dynamic> json) =>
      _DataProviders(data: _DataProvidersData.fromJson(json['data'] as Map<String, dynamic>? ?? {}));

  final _DataProvidersData data;
}

class _DataProvidersData {
  _DataProvidersData({required this.taskboardData});

  factory _DataProvidersData.fromJson(Map<String, dynamic> json) => _DataProvidersData(
    taskboardData: _MsVssWorkWebNewSprintsHubTaskboardDataProvider.fromJson(
      json['ms.vss-work-web.new-sprints-hub-taskboard-data-provider'] as Map<String, dynamic>? ??
          json['ms.vss-work-web.sprints-hub-taskboard-data-provider'] as Map<String, dynamic>? ??
          {},
    ),
  );

  final _MsVssWorkWebNewSprintsHubTaskboardDataProvider taskboardData;
}

class _MsVssWorkWebNewSprintsHubTaskboardDataProvider {
  _MsVssWorkWebNewSprintsHubTaskboardDataProvider({required this.taskboardModel});

  factory _MsVssWorkWebNewSprintsHubTaskboardDataProvider.fromJson(Map<String, dynamic> json) =>
      _MsVssWorkWebNewSprintsHubTaskboardDataProvider(
        taskboardModel: _TaskboardModel.fromJson(json['taskboardModel'] as Map<String, dynamic>? ?? {}),
      );

  final _TaskboardModel taskboardModel;
}

class _TaskboardModel {
  _TaskboardModel({required this.states, required this.types});

  factory _TaskboardModel.fromJson(Map<String, dynamic> json) => _TaskboardModel(
    states: List<String>.from(json['states'] as List<dynamic>? ?? []),
    types: List<String>.from((json['transitions'] as Map<String, dynamic>? ?? {}).keys.toList()),
  );

  final List<String> states;
  final List<String> types;
}
