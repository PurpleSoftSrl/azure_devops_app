import 'dart:convert';

import 'package:azure_devops/src/models/work_items.dart';
import 'package:http/src/response.dart';

class BoardsResponse {
  BoardsResponse({required this.boards});

  factory BoardsResponse.fromJson(Map<String, dynamic> json) => BoardsResponse(
        boards:
            List<Board>.from((json['value'] as List<dynamic>).map((x) => Board.fromJson(x as Map<String, dynamic>))),
      );

  final List<Board> boards;

  static List<Board> fromResponse(Response res) =>
      BoardsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).boards;
}

class Board {
  Board({
    required this.id,
    required this.name,
  });

  factory Board.fromJson(Map<String, dynamic> json) => Board(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  final String id;
  final String name;

  // Used to get the board's work items
  String? backlogId;
}

class BoardDetail {
  BoardDetail({
    required this.id,
    required this.name,
    required this.columns,
    required this.allowedMappings,
  });

  factory BoardDetail.fromJson(Map<String, dynamic> json) => BoardDetail(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        columns: List<BoardColumn>.from(
          (json['columns'] as List<dynamic>? ?? []).map((x) => BoardColumn.fromJson(x as Map<String, dynamic>)),
        ),
        allowedMappings: AllowedMappings.fromJson(json['allowedMappings'] as Map<String, dynamic>? ?? {}),
      );

  static BoardDetail fromResponse(Response res) => BoardDetail.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final String id;
  final String name;
  final List<BoardColumn> columns;
  final AllowedMappings allowedMappings;
}

class AllowedMappings {
  AllowedMappings({
    required this.incoming,
    required this.inProgress,
    required this.outgoing,
  });

  factory AllowedMappings.fromJson(Map<String, dynamic> json) => AllowedMappings(
        incoming: <String, List<String>>{
          for (final entry in (json['Incoming'] as Map<String, dynamic>? ?? {}).entries)
            entry.key: List<String>.from(entry.value as List<dynamic>),
        },
        inProgress: <String, List<String>>{
          for (final entry in (json['InProgress'] as Map<String, dynamic>? ?? {}).entries)
            entry.key: List<String>.from(entry.value as List<dynamic>),
        },
        outgoing: <String, List<String>>{
          for (final entry in (json['Outgoing'] as Map<String, dynamic>? ?? {}).entries)
            entry.key: List<String>.from(entry.value as List<dynamic>),
        },
      );

  final Map<String, List<String>> incoming;
  final Map<String, List<String>> inProgress;
  final Map<String, List<String>> outgoing;
}

class BoardColumn {
  BoardColumn({
    required this.id,
    required this.name,
    required this.itemLimit,
    required this.stateMappings,
    required this.columnType,
    required this.isSplit,
    required this.description,
  });

  factory BoardColumn.fromJson(Map<String, dynamic> json) => BoardColumn(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        itemLimit: json['itemLimit'] as int? ?? 0,
        stateMappings: json['stateMappings'] as Map<String, dynamic>? ?? {},
        columnType: json['columnType'] as String? ?? '',
        isSplit: json['isSplit'] as bool? ?? false,
        description: json['description'] as String? ?? '',
      );

  final String id;
  final String name;
  final int itemLimit;
  final Map<String, dynamic> stateMappings;
  final String columnType;
  final bool isSplit;
  final String description;

  @override
  bool operator ==(covariant BoardColumn other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class BoardDetailWithItems {
  BoardDetailWithItems({
    required this.board,
    required this.items,
  });

  final BoardDetail board;
  final List<WorkItem> items;
}

class BoardItemsResponse {
  BoardItemsResponse({required this.data});

  factory BoardItemsResponse.fromJson(Map<String, dynamic> json) => BoardItemsResponse(
        data: DataProvidersData.fromJson(json['dataProviders'] as Map<String, dynamic>? ?? {}),
      );

  static BoardItemsResponse fromResponse(Response res) =>
      BoardItemsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final DataProvidersData data;
}

class DataProvidersData {
  DataProvidersData({required this.content});

  factory DataProvidersData.fromJson(Map<String, dynamic> json) => DataProvidersData(
        content: MsVssWorkWebKanbanBoardContentDataProvider.fromJson(
          json['ms.vss-work-web.kanban-board-content-data-provider'] as Map<String, dynamic>? ?? {},
        ),
      );

  final MsVssWorkWebKanbanBoardContentDataProvider content;
}

class MsVssWorkWebKanbanBoardContentDataProvider {
  MsVssWorkWebKanbanBoardContentDataProvider({
    required this.boardModel,
  });

  factory MsVssWorkWebKanbanBoardContentDataProvider.fromJson(Map<String, dynamic> json) =>
      MsVssWorkWebKanbanBoardContentDataProvider(
        boardModel: BoardModel.fromJson(json['boardModel'] as Map<String, dynamic>? ?? {}),
      );

  final BoardModel boardModel;
}

class BoardModel {
  BoardModel({required this.itemSource});

  factory BoardModel.fromJson(Map<String, dynamic> json) => BoardModel(
        itemSource: ItemSource.fromJson(json['itemSource'] as Map<String, dynamic>? ?? {}),
      );

  final ItemSource itemSource;
}

class ItemSource {
  ItemSource({required this.payload});

  factory ItemSource.fromJson(Map<String, dynamic> json) => ItemSource(
        payload: Payload.fromJson(json['payload'] as Map<String, dynamic>? ?? {}),
      );

  final Payload payload;
}

class Payload {
  Payload({
    required this.rows,
    required this.orderedOutgoingIds,
  });

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        rows: List<int>.from(
          (json['rows'] as List<dynamic>? ?? [])
              .map((x) => List<dynamic>.from(x as List<dynamic>? ?? []))
              .map((l) => l.firstOrNull as int? ?? 0)
              .toList(),
        ),
        orderedOutgoingIds: List<int>.from((json['orderedOutgoingIds'] as List<dynamic>? ?? []).map((x) => x)),
      );

  final List<int> rows;
  final List<int> orderedOutgoingIds;
}
