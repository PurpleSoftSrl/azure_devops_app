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
    required this.initialState,
    required this.state,
  });

  final WorkItemTypeRules allRules;
  final Map<String, DynamicFieldData> initialFormFields;
  final Map<String, DynamicFieldData> formFields;
  final bool isEditing;
  final WorkItemState? initialState;
  final WorkItemState? state;

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

  /// Checks if any of the [rules] should be applied
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
    if (cond.isCreated && !isEditing) {
      // rule on create
      return true;
    }

    if (cond.isStateChanged && isEditing) {
      // rule on state changed
      return true;
    }

    if (cond.isStateNotChanged && initialState?.name == state?.name) {
      // rule on state not changed
      return true;
    }

    if (cond.isChangedFromState && cond.value == initialState?.name && isEditing) {
      // rule on state changed from
      return true;
    }

    if (cond.isChangedToState && cond.value == state?.name && isEditing) {
      // rule on state is
      return true;
    }

    if (cond.isStateNotEquals && cond.value != state?.name) {
      // rule on state is not
      return true;
    }

    if (cond.isFieldValueEquals(formFields)) {
      // rule on field value equals
      return true;
    }

    if (cond.isFieldValueNotEquals(formFields)) {
      // rule on field value not equals
      return true;
    }

    if (cond.isFieldValueChanged(formFields) && _fieldValueIsChanged(cond.field)) {
      // rule on field value changed
      return true;
    }

    if (cond.isFieldValueNotChanged(formFields) && _fieldValueIsNotChanged(cond.field)) {
      // rule on field value not changed
      return true;
    }

    return false;
  }

  bool _fieldValueIsChanged(String field) =>
      initialFormFields[field]?.text.formatted != formFields[field]?.text.formatted;

  bool _fieldValueIsNotChanged(String field) => !_fieldValueIsChanged(field);
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

extension on Condition {
  bool get _isStateField => field == 'System.State';

  bool get isStateNotChanged => conditionType.isWhenNotChanged && _isStateField && value == null;

  bool get isCreated => conditionType.isWhenWas && _isStateField && value == '';

  bool get isStateChanged => conditionType.isWhenChanged && _isStateField && value == null;

  bool get isChangedFromState => conditionType.isWhenWas && _isStateField;

  bool get isChangedToState => conditionType.isWhen && _isStateField;

  bool get isStateNotEquals => conditionType.isWhenNot && _isStateField;

  bool isFieldValueEquals(Map<String, DynamicFieldData> formFields) =>
      conditionType.isWhen && formFields[field] != null && formFields[field]!.text.formatted == value?.formatted;

  bool isFieldValueNotEquals(Map<String, DynamicFieldData> formFields) =>
      conditionType.isWhenNot && formFields[field] != null && formFields[field]!.text.formatted != value?.formatted;

  bool isFieldValueChanged(Map<String, DynamicFieldData> formFields) =>
      conditionType.isWhenChanged && formFields[field] != null && value == null;

  bool isFieldValueNotChanged(Map<String, DynamicFieldData> formFields) =>
      conditionType.isWhenNotChanged && value == null && formFields[field] != null;
}
