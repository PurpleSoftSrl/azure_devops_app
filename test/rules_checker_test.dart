import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/work_item_fields.dart';
import 'package:azure_devops/src/models/work_item_type_rules.dart';
import 'package:azure_devops/src/services/rules_checker.dart';
import 'package:flutter_test/flutter_test.dart';

const _stateField = 'System.State';
const _fieldNameToCheck = 'System.Description';

void main() {
  group('RulesChecker on create', () {
    test('Required field on create', () {
      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onCreate()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: false,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on create', () {
      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onCreate()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: false,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on create', () {
      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onCreate()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: false,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });

    test('Two fields, one required field and one read-only on create', () {
      const requiredFieldName = 'System.Description';
      const readOnlyFieldName = 'System.Priority';

      final checker = RulesChecker(
        allRules: {
          requiredFieldName: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onCreate()],
            ),
          ],
          readOnlyFieldName: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onCreate()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {
          requiredFieldName: DynamicFieldData(required: false),
          readOnlyFieldName: DynamicFieldData(required: false),
        },
        isEditing: false,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: requiredFieldName, name: 'Description'));

      _expectIsRequired(result);

      final result2 = checker.checkRules(WorkItemField(referenceName: readOnlyFieldName, name: 'Priority'));

      _expectIsReadOnly(result2);
    });
  });

  group('RulesChecker on state changed', () {
    test('Required field on state changed', () {
      const previousState = 'New';
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onStateChanged()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on state changed', () {
      const previousState = 'New';
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onStateChanged()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on state changed', () {
      const previousState = 'New';
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onStateChanged()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on state not changed', () {
    test('Required field on state not changed', () {
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onStateNotChanged()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: currentState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on state not changed', () {
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onStateNotChanged()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: currentState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on state not changed', () {
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onStateNotChanged()],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: currentState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on state changed from', () {
    test('Required field on state changed from', () {
      const previousState = 'Active';
      const currentState = 'Done';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onStateChangedFrom(previousState)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on state changed from', () {
      const previousState = 'Active';
      const currentState = 'Done';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onStateChangedFrom(previousState)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on state changed from', () {
      const previousState = 'Active';
      const currentState = 'Done';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onStateChangedFrom(previousState)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on state changed to', () {
    test('Required field on state changed to', () {
      const previousState = 'Active';
      const currentState = 'Done';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onStateChangedTo(currentState)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on state changed to', () {
      const previousState = 'Active';
      const currentState = 'Done';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onStateChangedTo(currentState)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on state changed to', () {
      const previousState = 'Active';
      const currentState = 'Done';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onStateChangedTo(currentState)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: previousState, color: ''),
        state: WorkItemState(id: '', name: currentState, color: ''),
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on state is not', () {
    test('Required field on state is not', () {
      const stateToCheck = 'Done';
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onStateIsNot(stateToCheck)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: currentState, color: ''),
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on state is not', () {
      const stateToCheck = 'Done';
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onStateIsNot(stateToCheck)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: currentState, color: ''),
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on state is not', () {
      const stateToCheck = 'Done';
      const currentState = 'Active';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onStateIsNot(stateToCheck)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {_fieldNameToCheck: DynamicFieldData(required: false)},
        isEditing: true,
        initialState: WorkItemState(id: '', name: currentState, color: ''),
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on field value is', () {
    test('Required field on field value is', () {
      const fieldNameWithValue = 'System.Effort';
      const value = '2';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onFieldValueIs(fieldNameWithValue, value)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          fieldNameWithValue: DynamicFieldData(required: false)..text = value,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on field value is', () {
      const fieldNameWithValue = 'System.Effort';
      const value = '2';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onFieldValueIs(fieldNameWithValue, value)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          fieldNameWithValue: DynamicFieldData(required: false)..text = value,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on field value is', () {
      const fieldNameWithValue = 'System.Effort';
      const value = '2';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onFieldValueIs(fieldNameWithValue, value)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          fieldNameWithValue: DynamicFieldData(required: false)..text = value,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on field value is not', () {
    test('Required field on field value is not', () {
      const fieldNameWithValue = 'System.Effort';
      const initialValue = '2';
      const changedValue = '3';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onFieldValueIsNot(fieldNameWithValue, initialValue)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          fieldNameWithValue: DynamicFieldData(required: false)..text = changedValue,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on field value is not', () {
      const fieldNameWithValue = 'System.Effort';
      const initialValue = '2';
      const changedValue = '3';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onFieldValueIsNot(fieldNameWithValue, initialValue)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          fieldNameWithValue: DynamicFieldData(required: false)..text = changedValue,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on field value is not', () {
      const fieldNameWithValue = 'System.Effort';
      const initialValue = '2';
      const changedValue = '3';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onFieldValueIsNot(fieldNameWithValue, initialValue)],
            ),
          ],
        },
        initialFormFields: {},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          fieldNameWithValue: DynamicFieldData(required: false)..text = changedValue,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on field value changed', () {
    test('Required field on field value changed', () {
      const changedFieldName = 'System.Effort';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onFieldValueChanged(changedFieldName)],
            ),
          ],
        },
        initialFormFields: {changedFieldName: DynamicFieldData(required: false)..text = '2'},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          changedFieldName: DynamicFieldData(required: false)..text = '3',
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on field value changed', () {
      const changedFieldName = 'System.Effort';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onFieldValueChanged(changedFieldName)],
            ),
          ],
        },
        initialFormFields: {changedFieldName: DynamicFieldData(required: false)..text = '2'},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          changedFieldName: DynamicFieldData(required: false)..text = '3',
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on field value changed', () {
      const changedFieldName = 'System.Effort';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onFieldValueChanged(changedFieldName)],
            ),
          ],
        },
        initialFormFields: {changedFieldName: DynamicFieldData(required: false)..text = '2'},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          changedFieldName: DynamicFieldData(required: false)..text = '3',
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });

  group('RulesChecker on field value not changed', () {
    test('Required field on field value not changed', () {
      const notChangedFieldName = 'System.Effort';
      final notChangedField = DynamicFieldData(required: false)..text = '2';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeRequired),
              conditions: [ConditionCreator.onFieldValueNotChanged(notChangedFieldName)],
            ),
          ],
        },
        initialFormFields: {notChangedFieldName: notChangedField},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          notChangedFieldName: notChangedField,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsRequired(result);
    });

    test('Read-only field on field value not changed', () {
      const notChangedFieldName = 'System.Effort';
      final notChangedField = DynamicFieldData(required: false)..text = '2';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.makeReadOnly),
              conditions: [ConditionCreator.onFieldValueNotChanged(notChangedFieldName)],
            ),
          ],
        },
        initialFormFields: {notChangedFieldName: notChangedField},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          notChangedFieldName: notChangedField,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsReadOnly(result);
    });

    test('Set value to empty field on field value not changed', () {
      const notChangedFieldName = 'System.Effort';
      final notChangedField = DynamicFieldData(required: false)..text = '2';

      final checker = RulesChecker(
        allRules: {
          _fieldNameToCheck: [
            (
              action: ActionCreator.fromActionType(ActionType.setValueToEmpty),
              conditions: [ConditionCreator.onFieldValueNotChanged(notChangedFieldName)],
            ),
          ],
        },
        initialFormFields: {notChangedFieldName: notChangedField},
        formFields: {
          _fieldNameToCheck: DynamicFieldData(required: false),
          notChangedFieldName: notChangedField,
        },
        isEditing: true,
        initialState: null,
        state: null,
      );

      final result = checker.checkRules(WorkItemField(referenceName: _fieldNameToCheck, name: 'Description'));

      _expectIsSetValueToEmpty(result);
    });
  });
}

void _expectIsRequired(RulesResult result) {
  expect(result.required, isTrue);
  expect(result.readOnly, isFalse);
  expect(result.makeEmpty, isFalse);
}

void _expectIsReadOnly(RulesResult result) {
  expect(result.required, isFalse);
  expect(result.readOnly, isTrue);
  expect(result.makeEmpty, isFalse);
}

void _expectIsSetValueToEmpty(RulesResult result) {
  expect(result.required, isFalse);
  expect(result.readOnly, isFalse);
  expect(result.makeEmpty, isTrue);
}

class ConditionCreator {
  static Condition onCreate() => Condition(conditionType: ConditionType.whenWas, field: _stateField, value: '');

  static Condition onStateChanged() =>
      Condition(conditionType: ConditionType.whenChanged, field: _stateField, value: null);

  static Condition onStateNotChanged() =>
      Condition(conditionType: ConditionType.whenNotChanged, field: _stateField, value: null);

  static Condition onStateChangedFrom(String value) =>
      Condition(conditionType: ConditionType.whenWas, field: _stateField, value: value);

  static Condition onStateChangedTo(String value) =>
      Condition(conditionType: ConditionType.when, field: _stateField, value: value);

  static Condition onStateIsNot(String value) =>
      Condition(conditionType: ConditionType.whenNot, field: _stateField, value: value);

  static Condition onFieldValueIs(String fieldName, String value) =>
      Condition(conditionType: ConditionType.when, field: fieldName, value: value);

  static Condition onFieldValueIsNot(String fieldName, String value) =>
      Condition(conditionType: ConditionType.whenNot, field: fieldName, value: value);

  static Condition onFieldValueChanged(String fieldName) =>
      Condition(conditionType: ConditionType.whenChanged, field: fieldName, value: null);

  static Condition onFieldValueNotChanged(String fieldName) =>
      Condition(conditionType: ConditionType.whenNotChanged, field: fieldName, value: null);
}

class ActionCreator {
  static Action fromActionType(ActionType actionType) => Action(actionType: actionType, targetField: '');
}
