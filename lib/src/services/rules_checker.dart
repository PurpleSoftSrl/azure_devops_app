import 'package:azure_devops/src/extensions/string_extension.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/work_item_fields.dart';
import 'package:azure_devops/src/models/work_item_type_rules.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

typedef RulesResult = ({bool readOnly, bool required});

/// Work items rules checker.
///
/// A rule can have a maximum of 2 conditions, and if they're all true, then
/// the actions (maximum 10) will be applied.
class RulesChecker {
  RulesChecker({
    required this.allRules,
    required this.initialFormFields,
    required this.formFields,
    required this.isEditing,
    required this.initialStatus,
    required this.status,
  });

  final WorkItemTypeRules allRules;
  final Map<String, DynamicFieldData> initialFormFields;
  final Map<String, DynamicFieldData> formFields;
  final bool isEditing;
  final WorkItemState? initialStatus;
  final WorkItemState? status;

  /// Checks if `readOnly` or `required` actions should be applied to [field].
  RulesResult checkRules(WorkItemField field) {
    final readOnly = _checkIfIsReadOnly(field);
    final required = _checkIfIsRequired(field);
    assert(!readOnly || !required, 'A field cannot be both readOnly and required. Field: ${field.referenceName}');
    return (readOnly: readOnly, required: required);
  }

  /// Checks whether this field should be read-only according to the rules.
  bool _checkIfIsReadOnly(WorkItemField field) {
    final rules = allRules[field.referenceName] ?? [];
    if (rules.isEmpty) return false;

    final makeReadOnlyActions = rules.where((r) => r.action == ActionType.makeReadOnly).toList();
    if (makeReadOnlyActions.isEmpty) return false;

    return _checkIfMatchesRule(rules);
  }

  /// Checks whether this field should be required according to the rules.
  bool _checkIfIsRequired(WorkItemField field) {
    final rules = allRules[field.referenceName] ?? [];
    if (rules.isEmpty) return false;

    final makeRequiredActions = rules.where((r) => r.action == ActionType.makeRequired).toList();
    if (makeRequiredActions.isEmpty) return false;

    return _checkIfMatchesRule(rules);
  }

  bool _checkIfMatchesRule(List<WorkItemRule> rules) {
    var isReadOnly = false;

    for (final rule in rules) {
      final conditions = rule.conditions;
      if (conditions.isEmpty) break;

      if (conditions.length == 1) {
        final cond = conditions.single;
        isReadOnly |= _checkSingleRule(cond);
        continue;
      }

      // we have 2 conditions
      final firstCond = conditions.first;
      final secondCond = conditions.last;
      isReadOnly |= _checkSingleRule(firstCond) && _checkSingleRule(secondCond);
    }

    return isReadOnly;
  }

  bool _checkSingleRule(Condition cond) {
    if (cond.conditionType == ConditionType.whenNotChanged &&
        cond.field == 'System.State' &&
        cond.value == null &&
        initialStatus?.name == status?.name) {
      // rule on state not changed
      return true;
    }

    if (cond.conditionType == ConditionType.whenWas && cond.field == 'System.State' && cond.value == '' && !isEditing) {
      // rule on create
      return true;
    }

    if (cond.conditionType == ConditionType.whenChanged &&
        cond.field == 'System.State' &&
        cond.value == null &&
        isEditing) {
      // rule on change state
      return true;
    }

    if (cond.conditionType == ConditionType.whenChanged &&
        formFields[cond.field] != null &&
        cond.value == null &&
        initialFormFields[cond.field]?.text.formatted != formFields[cond.field]?.text.formatted) {
      // rule on change field value
      return true;
    }

    if (cond.conditionType == ConditionType.whenNotChanged &&
        formFields[cond.field] != null &&
        cond.value == null &&
        initialFormFields[cond.field]?.text.formatted == formFields[cond.field]?.text.formatted) {
      // rule on field value not changed
      return true;
    }

    if (cond.conditionType == ConditionType.whenWas &&
        cond.field == 'System.State' &&
        cond.value == initialStatus?.name &&
        isEditing) {
      // rule on change from state
      return true;
    }

    if (cond.conditionType == ConditionType.when &&
        cond.field == 'System.State' &&
        cond.value == status?.name &&
        isEditing) {
      // rule on change to state
      return true;
    }

    if (cond.conditionType == ConditionType.when &&
        formFields[cond.field] != null &&
        formFields[cond.field]!.text.formatted == cond.value?.formatted) {
      // rule on field value equals
      return true;
    }

    if (cond.conditionType == ConditionType.whenNot && cond.field == 'System.State' && cond.value != status?.name) {
      // rule on state not equals
      return true;
    }

    if (cond.conditionType == ConditionType.whenNot &&
        formFields[cond.field] != null &&
        formFields[cond.field]!.text.formatted != cond.value?.formatted) {
      // rule on field value not equals
      return true;
    }

    return false;
  }
}

class DynamicFieldData {
  DynamicFieldData({required this.required});

  String text = '';
  GlobalKey<FormFieldState<dynamic>> formFieldKey = GlobalKey();
  TextEditingController controller = TextEditingController();

  // Used to ensure editor is visible when keyboard is opened
  GlobalKey<State>? editorGlobalKey;
  HtmlEditorController? editorController;
  String? editorInitialText;
  GlobalKey<PopupMenuButtonState<dynamic>>? popupMenuKey;

  final bool required;
}
