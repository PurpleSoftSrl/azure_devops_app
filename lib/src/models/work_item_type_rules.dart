import 'dart:convert';

import 'package:http/http.dart';

class WorkItemTypeRulesResponse {
  WorkItemTypeRulesResponse({required this.rules});

  factory WorkItemTypeRulesResponse.fromResponse(Response res) =>
      WorkItemTypeRulesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  factory WorkItemTypeRulesResponse.fromJson(Map<String, dynamic> json) => WorkItemTypeRulesResponse(
        rules: List<Rule>.from(
          (json['value'] as List<dynamic>).map((v) => Rule.fromJson(v as Map<String, dynamic>)),
        ),
      );

  final List<Rule> rules;
}

class Rule {
  Rule({
    required this.id,
    required this.conditions,
    required this.actions,
    required this.isDisabled,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        id: json['id'] as String,
        conditions: List<Condition>.from(
          (json['conditions'] as List<dynamic>).map((c) => Condition.fromJson(c as Map<String, dynamic>)),
        ),
        actions: List<Action>.from(
          (json['actions'] as List<dynamic>).map((a) => Action.fromJson(a as Map<String, dynamic>)),
        ),
        isDisabled: json['isDisabled'] as bool? ?? false,
      );

  final String id;
  final List<Condition> conditions;
  final List<Action> actions;
  final bool isDisabled;
}

class Action {
  Action({
    required this.actionType,
    required this.targetField,
    this.value,
  });

  factory Action.fromJson(Map<String, dynamic> json) => Action(
        actionType: ActionType.fromString(json['actionType']?.toString() ?? ''),
        targetField: json['targetField'] as String,
        value: json['value'] as String?,
      );

  final ActionType actionType;
  final String targetField;
  final String? value;

  @override
  String toString() => 'Action(actionType: $actionType, targetField: $targetField)';
}

enum ActionType {
  makeReadOnly,
  makeRequired,
  setValueToEmpty,
  disallowValue,
  notSupported;

  static ActionType fromString(String str) {
    switch (str) {
      case 'makeReadOnly':
        return ActionType.makeReadOnly;
      case 'makeRequired':
        return ActionType.makeRequired;
      case 'setValueToEmpty':
        return ActionType.setValueToEmpty;
      case 'disallowValue':
        return ActionType.disallowValue;
      default:
        return ActionType.notSupported;
    }
  }
}

class Condition {
  Condition({
    required this.conditionType,
    required this.field,
    required this.value,
  });

  factory Condition.fromJson(Map<String, dynamic> json) => Condition(
        conditionType: ConditionType.fromString(json['conditionType'] as String? ?? ''),
        field: json['field'] as String? ?? '',
        value: json['value'] as String?,
      );

  final ConditionType conditionType;
  final String field;
  final String? value;

  @override
  String toString() => 'Condition(conditionType: $conditionType, field: $field, value: $value)';
}

enum ConditionType {
  when,
  whenNot,
  whenChanged,
  whenNotChanged,
  whenWas,
  unsupported;

  static ConditionType fromString(String str) {
    return switch (str) {
      'when' => ConditionType.when,
      'whenNot' => ConditionType.whenNot,
      'whenChanged' => ConditionType.whenChanged,
      'whenNotChanged' => ConditionType.whenNotChanged,
      'whenWas' => ConditionType.whenWas,
      _ => ConditionType.unsupported,
    };
  }

  bool get isWhen => this == ConditionType.when;
  bool get isWhenNot => this == ConditionType.whenNot;
  bool get isWhenChanged => this == ConditionType.whenChanged;
  bool get isWhenNotChanged => this == ConditionType.whenNotChanged;
  bool get isWhenWas => this == ConditionType.whenWas;
}
