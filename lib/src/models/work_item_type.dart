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
            List<State>.from((json['states'] as List<dynamic>).map((s) => State.fromJson(s as Map<String, dynamic>))),
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
  final List<State> states;
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

class State {
  factory State.fromRawJson(String str) => State.fromJson(json.decode(str) as Map<String, dynamic>);

  factory State.fromJson(Map<String, dynamic> json) => State(
        name: json['name'] as String,
        color: json['color'] as String,
        category: categoryValues.map[json['category']]!,
      );

  State({
    required this.name,
    required this.color,
    required this.category,
  });

  final String name;
  final String color;
  final Category category;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
        'category': categoryValues.reverse[category],
      };
}

enum Category { proposed, inProgress, resolved, completed, removed }

final categoryValues = EnumValues({
  'Completed': Category.completed,
  'InProgress': Category.inProgress,
  'Proposed': Category.proposed,
  'Removed': Category.removed,
  'Resolved': Category.resolved,
});

class Transition {
  factory Transition.fromRawJson(String str) => Transition.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Transition.fromJson(Map<String, dynamic> json) => Transition(
        to: json['to'] as String,
        actions: json['actions'] == null ? [] : List<String>.from((json['actions'] as List<dynamic>).map((x) => x)),
      );

  Transition({
    required this.to,
    this.actions,
  });

  final String to;
  final List<String>? actions;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'to': to,
        'actions': actions == null ? <dynamic>[] : List<dynamic>.from(actions!.map((x) => x)),
      };
}

class EnumValues<T> {
  EnumValues(this.map);
  Map<String, T> map;
  late Map<T, String> reverseMap;

  Map<T, String> get reverse {
    return reverseMap = map.map((k, v) => MapEntry(v, k));
  }
}
