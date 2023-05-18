import 'dart:convert';

class WorkItemTypesResponse {
  factory WorkItemTypesResponse.fromRawJson(String str) =>
      WorkItemTypesResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  factory WorkItemTypesResponse.fromJson(Map<String, dynamic> json) => WorkItemTypesResponse(
        count: json['count'] as int,
        types: List<WorkItemType>.from(
          (json['value'] as List<dynamic>).map((v) => WorkItemType.fromJson(v as Map<String, dynamic>)),
        ),
      );

  WorkItemTypesResponse({
    required this.count,
    required this.types,
  });

  final int count;
  final List<WorkItemType> types;
}

class WorkItemType {
  factory WorkItemType.fromRawJson(String str) => WorkItemType.fromJson(json.decode(str) as Map<String, dynamic>);

  factory WorkItemType.fromJson(Map<String, dynamic> json) => WorkItemType(
        name: json['name'] as String,
        referenceName: json['referenceName'] as String,
        description: json['description'] as String?,
        color: json['color'] as String,
        isDisabled: json['isDisabled'] as bool,
        states:
            List<_State>.from((json['states'] as List<dynamic>).map((s) => _State.fromJson(s as Map<String, dynamic>))),
        url: json['url'] as String,
      );

  WorkItemType({
    required this.name,
    required this.referenceName,
    required this.description,
    required this.color,
    required this.isDisabled,
    required this.states,
    required this.url,
  });

  final String name;
  final String referenceName;
  final String? description;
  final String color;
  final bool isDisabled;
  final List<_State> states;
  final String url;

  static WorkItemType get all {
    return WorkItemType(
      name: 'All',
      referenceName: 'All',
      description: 'All types',
      color: '',
      isDisabled: false,
      states: [],
      url: '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkItemType && other.name == name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }
}

class _State {
  factory _State.fromJson(Map<String, dynamic> json) => _State(
        name: json['name'] as String,
        color: json['color'] as String,
        category: _categoryValues.map[json['category']]!,
      );

  _State({
    required this.name,
    required this.color,
    required this.category,
  });

  final String name;
  final String color;
  final _Category category;
}

enum _Category { proposed, inProgress, resolved, completed, removed }

final _categoryValues = _EnumValues({
  'Completed': _Category.completed,
  'InProgress': _Category.inProgress,
  'Proposed': _Category.proposed,
  'Removed': _Category.removed,
  'Resolved': _Category.resolved,
});

class _EnumValues<T> {
  _EnumValues(this.map);
  Map<String, T> map;
  late Map<T, String> reverseMap;

  Map<T, String> get reverse {
    return reverseMap = map.map((k, v) => MapEntry(v, k));
  }
}
