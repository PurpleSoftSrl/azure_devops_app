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
    required this.fields,
  });

  factory BoardDetail.fromJson(Map<String, dynamic> json) => BoardDetail(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        columns: List<BoardColumn>.from(
          (json['columns'] as List<dynamic>? ?? []).map((x) => BoardColumn.fromJson(x as Map<String, dynamic>)),
        ),
        allowedMappings: AllowedMappings.fromJson(json['allowedMappings'] as Map<String, dynamic>? ?? {}),
        fields: BoardFields.fromJson(json['fields'] as Map<String, dynamic>? ?? {}),
      );

  static BoardDetail fromResponse(Response res) => BoardDetail.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final String id;
  final String name;
  final List<BoardColumn> columns;
  final AllowedMappings allowedMappings;
  final BoardFields fields;
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

  factory BoardColumn.fromState({required String state}) => BoardColumn(
        id: state,
        name: state,
        itemLimit: 0,
        stateMappings: {},
        columnType: '',
        isSplit: false,
        description: '',
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

class BoardFields {
  BoardFields({required this.columnField});

  factory BoardFields.fromJson(Map<String, dynamic> json) => BoardFields(
        columnField: BoardField.fromJson(json['columnField'] as Map<String, dynamic>? ?? {}),
      );

  final BoardField columnField;
}

class BoardField {
  BoardField({required this.referenceName});

  factory BoardField.fromJson(Map<String, dynamic> json) => BoardField(
        referenceName: json['referenceName'] as String? ?? '',
      );

  final String referenceName;
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
        data: _DataProvidersData.fromJson(json['dataProviders'] as Map<String, dynamic>? ?? {}),
      );

  static BoardItemsResponse fromResponse(Response res) =>
      BoardItemsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  final _DataProvidersData data;
}

class _DataProvidersData {
  _DataProvidersData({required this.content});

  factory _DataProvidersData.fromJson(Map<String, dynamic> json) => _DataProvidersData(
        content: _MsVssWorkWebKanbanBoardContentDataProvider.fromJson(
          json['ms.vss-work-web.kanban-board-content-data-provider'] as Map<String, dynamic>? ?? {},
        ),
      );

  final _MsVssWorkWebKanbanBoardContentDataProvider content;
}

class _MsVssWorkWebKanbanBoardContentDataProvider {
  _MsVssWorkWebKanbanBoardContentDataProvider({
    required this.boardModel,
  });

  factory _MsVssWorkWebKanbanBoardContentDataProvider.fromJson(Map<String, dynamic> json) =>
      _MsVssWorkWebKanbanBoardContentDataProvider(
        boardModel: _BoardModel.fromJson(json['boardModel'] as Map<String, dynamic>? ?? {}),
      );

  final _BoardModel boardModel;
}

class _BoardModel {
  _BoardModel({required this.itemSource});

  factory _BoardModel.fromJson(Map<String, dynamic> json) => _BoardModel(
        itemSource: _ItemSource.fromJson(json['itemSource'] as Map<String, dynamic>? ?? {}),
      );

  final _ItemSource itemSource;
}

class _ItemSource {
  _ItemSource({required this.payload});

  factory _ItemSource.fromJson(Map<String, dynamic> json) => _ItemSource(
        payload: _Payload.fromJson(json['payload'] as Map<String, dynamic>? ?? {}),
      );

  final _Payload payload;
}

class _Payload {
  _Payload({
    required this.rows,
    required this.orderedOutgoingIds,
  });

  factory _Payload.fromJson(Map<String, dynamic> json) => _Payload(
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
