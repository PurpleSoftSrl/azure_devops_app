// ignore_for_file: use_setters_to_change_properties

part of create_or_edit_work_item;

class _CreateOrEditWorkItemController with FilterMixin, AppLogger {
  factory _CreateOrEditWorkItemController({
    required AzureApiService apiService,
    required CreateOrEditWorkItemArgs args,
    required StorageService storageService,
  }) {
    return instance ??= _CreateOrEditWorkItemController._(apiService, args, storageService);
  }

  _CreateOrEditWorkItemController._(this.apiService, this.args, this.storageService);

  static _CreateOrEditWorkItemController? instance;

  final AzureApiService apiService;
  final StorageService storageService;
  final CreateOrEditWorkItemArgs args;

  final hasChanged = ValueNotifier<ApiResponse<bool>?>(null);

  final titleFieldKey = GlobalKey<FormFieldState<dynamic>>();

  List<WorkItemType> allWorkItemTypes = [WorkItemType.all];
  Map<String, List<WorkItemType>> allProjectsWorkItemTypes = {};
  List<WorkItemState> allWorkItemStates = [WorkItemState.all];

  LabeledWorkItemFields fieldsToShow = {};
  WorkItemTypeRules allRules = {};

  late List<WorkItemType> projectWorkItemTypes = allWorkItemTypes;

  String newWorkItemTitle = '';
  String newWorkItemDescription = '';

  final unassigned = GraphUser(displayName: 'Unassigned');
  late GraphUser newWorkItemAssignedTo = unassigned;
  late WorkItemType newWorkItemType = allWorkItemTypes.first;
  late Project newWorkItemProject = getProjects(storageService).firstWhereOrNull((p) => p.id != '-1') ?? projectAll;

  // Used only in edit mode
  WorkItemState? newWorkItemStatus;

  /// Used to compare current state to initial one for rules validation
  WorkItemState? _initialWorkItemStatus;

  AreaOrIteration? newWorkItemArea;
  AreaOrIteration? newWorkItemIteration;

  bool get isEditing => args.id != null;
  WorkItem? editingWorkItem;

  /// Data used to read/write each field. The keys are fields' reference names.
  final formFields = <String, _DynamicFieldData>{};

  /// Used to compare current fields values to initial ones for rules validation
  Map<String, _DynamicFieldData> _initialFormFields = {};

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    if (args.id != null) {
      // edit existent work item
      final res = await apiService.getWorkItemDetail(projectName: args.project!, workItemId: args.id!);
      if (!res.isError) {
        _setFields(res.data!.item);
      }
    }

    final types = await apiService.getWorkItemTypes();
    if (!types.isError) {
      allWorkItemTypes.addAll(types.data!.values.expand((ts) => ts).toSet());
      allProjectsWorkItemTypes = types.data!;

      if (!isEditing) {
        final allStatesToAdd = <WorkItemState>{};

        for (final entry in apiService.workItemStates.values) {
          final states = entry.values.expand((v) => v);
          allStatesToAdd.addAll(states);
        }

        final sortedStates = allStatesToAdd.sorted((a, b) => a.name.compareTo(b.name));

        allWorkItemStates.addAll(sortedStates);
      }
    }

    if (newWorkItemType != WorkItemType.all) await _getTypeFormFields();

    _refreshPage();
  }

  void _setFields(WorkItem item) {
    editingWorkItem = item;
    final fields = item.fields;
    final project = fields.systemTeamProject;
    final workItemType = fields.systemWorkItemType;

    projectWorkItemTypes = apiService.workItemTypes[project] ?? <WorkItemType>[];
    allWorkItemStates = apiService.workItemStates[project]?[workItemType] ?? [];

    newWorkItemTitle = fields.systemTitle;
    newWorkItemDescription = fields.systemDescription ?? '';

    if (fields.systemAssignedTo != null) {
      newWorkItemAssignedTo =
          getSortedUsers(apiService).firstWhereOrNull((u) => u.mailAddress == fields.systemAssignedTo?.uniqueName) ??
              unassigned;
    }

    newWorkItemType = projectWorkItemTypes.firstWhereOrNull((t) => t.name == workItemType) ??
        WorkItemType(
          name: workItemType,
          referenceName: workItemType,
          isDisabled: false,
          icon: '',
          states: [],
        );

    _initialWorkItemStatus = newWorkItemStatus =
        apiService.workItemStates[project]?[workItemType]?.firstWhereOrNull((s) => s.name == fields.systemState) ??
            WorkItemState(
              id: '',
              name: fields.systemState,
              color: 'FFFFFF',
            );

    newWorkItemArea = AreaOrIteration.onlyPath(path: fields.systemAreaPath);
    newWorkItemIteration = AreaOrIteration.onlyPath(path: fields.systemIterationPath);
  }

  Future<void> setType(WorkItemType type) async {
    if (type == newWorkItemType) return;

    newWorkItemType = type;

    if (isEditing) {
      final project = editingWorkItem!.fields.systemTeamProject;
      final workItemType = newWorkItemType.name;
      allWorkItemStates = apiService.workItemStates[project]![workItemType] ?? [];
      if (!allWorkItemStates.contains(newWorkItemStatus)) {
        // change status if new type doesn't support current status
        newWorkItemStatus = allWorkItemStates.firstOrNull ?? newWorkItemStatus;
      }
    }

    await _getTypeFormFields();

    _setHasChanged();
  }

  Future<void> setProject(Project project) async {
    if (project == newWorkItemProject) return;

    newWorkItemProject = project;

    if (!isEditing && newWorkItemProject != projectAll) {
      projectWorkItemTypes =
          allProjectsWorkItemTypes[newWorkItemProject.name]?.where((t) => t != WorkItemType.all).toList() ?? [];

      if (!projectWorkItemTypes.contains(newWorkItemType) && projectWorkItemTypes.isNotEmpty) {
        newWorkItemType = projectWorkItemTypes.first;
      }
    }

    await _getTypeFormFields();

    _setHasChanged();
  }

  void setAssignee(GraphUser assignee) {
    if (assignee == newWorkItemAssignedTo) return;

    newWorkItemAssignedTo = assignee;
    _setHasChanged();
  }

  void setArea(AreaOrIteration? area) {
    if (area == newWorkItemArea) return;

    newWorkItemArea = area;
    _setHasChanged();
  }

  void setIteration(AreaOrIteration? iteration) {
    if (iteration == newWorkItemIteration) return;

    newWorkItemIteration = iteration;
    _setHasChanged();
  }

  void setState(WorkItemState state) {
    if (state == newWorkItemStatus) return;

    newWorkItemStatus = state;
    _setHasChanged();

    _checkRules();
    _refreshPage();
  }

  void onTitleChanged(String value) {
    newWorkItemTitle = value;
    _setHasChanged();
  }

  void _setHasChanged() {
    hasChanged.value = ApiResponse.ok(true);
  }

  void _refreshPage() {
    hasChanged.value = hasChanged.value?.copyWith() ?? ApiResponse.ok(false);
  }

  Future<void> confirm() async {
    if (!titleFieldKey.currentState!.validate()) {
      _showFormValidationError('Title');
      return;
    }

    for (final key in formFields.entries) {
      final state = key.value.formFieldKey.currentState;
      if (state == null) continue;

      if (!state.validate()) {
        final field = fieldsToShow.values.expand((f) => f).firstWhereOrNull((f) => f.referenceName == key.key);
        _showFormValidationError(field?.name ?? key.key);
        return;
      }
    }

    final htmlFieldsToShow = fieldsToShow.values.expand((f) => f).where((f) => f.type == 'html');
    for (final field in htmlFieldsToShow) {
      final formField = formFields[field.referenceName];
      final text = await formField?.editorController?.getText() ?? '';

      if (field.required && text.isEmpty) {
        _showFormValidationError(field.name);
        return;
      }

      formField?.text = text;
    }

    final errorMessage = _checkRequiredFields();
    if (errorMessage != null) return OverlayService.snackbar(errorMessage, isError: true);

    final assignedTo = newWorkItemAssignedTo == unassigned ? GraphUser(mailAddress: '') : newWorkItemAssignedTo;

    final res = isEditing ? await _editWorkItem(assignedTo) : await _createWorkItem(assignedTo);

    logAnalytics('${isEditing ? 'edited' : 'created'}_work_item', {
      'work_item_type': newWorkItemType.name,
      'is_error': res.isError.toString(),
      'customization': newWorkItemType.customization,
    });

    if (res.isError) {
      final isInherited = ![null, 'system'].contains(newWorkItemType.customization);
      var description = 'Work item not ${isEditing ? 'edited' : 'created'}.';
      if (isInherited) {
        description += '\nInherited processes are not fully supported yet.';
      }
      return OverlayService.error(
        'Error',
        description: description,
      );
    }

    OverlayService.snackbar('Changes saved');
    hasChanged.value = ApiResponse.ok(false);

    if (!isEditing) {
      AppRouter.pop();
    } else {
      _resetInitialFormFields();
    }
  }

  void _showFormValidationError(String fieldName) {
    OverlayService.snackbar("Field '$fieldName' is required", isError: true);
  }

  /// When the user navigates to this page, and after each confirmed change,
  /// we have to reset [_initialFormFields] to restart rules validation from current state.
  void _resetInitialFormFields() {
    _initialFormFields = {
      for (final field in formFields.entries)
        field.key: _DynamicFieldData(required: field.value.required)
          ..controller = field.value.controller
          ..text = field.value.controller.text.formatted
          ..editorController = field.value.editorController
          ..editorGlobalKey = field.value.editorGlobalKey
          ..editorInitialText = field.value.editorInitialText
          ..formFieldKey = field.value.formFieldKey
          ..popupMenuKey = field.value.popupMenuKey
          ..text = field.value.text,
    };
  }

  String? _checkRequiredFields() {
    if (isEditing && newWorkItemTitle.isEmpty) return 'Title cannot be empty';
    if (isEditing) return null;

    String? errorMessage;
    if (newWorkItemProject == projectAll || newWorkItemType == WorkItemType.all || newWorkItemTitle.isEmpty) {
      if (newWorkItemProject == projectAll) {
        errorMessage = 'Project must be selected';
      } else if (newWorkItemType == WorkItemType.all) {
        errorMessage = 'Type must be selected';
      } else {
        errorMessage = 'Title cannot be empty';
      }
    }

    return errorMessage;
  }

  Future<ApiResponse<WorkItem>> _editWorkItem(GraphUser? assignedTo) async {
    final res = await apiService.editWorkItem(
      projectName: args.project!,
      id: args.id!,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: assignedTo,
      description: newWorkItemDescription,
      status: newWorkItemStatus?.name,
      area: newWorkItemArea,
      iteration: newWorkItemIteration,
      formFields: {for (final field in formFields.entries) field.key: field.value.text},
    );
    return res;
  }

  Future<ApiResponse<WorkItem>> _createWorkItem(GraphUser? assignedTo) async {
    final res = await apiService.createWorkItem(
      projectName: newWorkItemProject.name!,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: assignedTo,
      description: newWorkItemDescription,
      area: newWorkItemArea,
      iteration: newWorkItemIteration,
      formFields: {for (final field in formFields.entries) field.key: field.value.text},
    );
    return res;
  }

  Future<void> addMention(GraphUser u, String fieldRefName) async {
    final res = await apiService.getUserToMention(email: u.mailAddress!);
    if (res.isError || res.data == null) {
      return OverlayService.snackbar('Could not find user', isError: true);
    }

    // remove `(me)` from user name if it's me
    final name = u.mailAddress == apiService.user!.emailAddress ? apiService.user!.displayName : u.displayName;
    final mention = '<a href="#" data-vss-mention="version:2.0,${res.data}">@$name</a>';
    formFields[fieldRefName]?.editorController?.insertHtml(mention);
  }

  List<GraphUser> getAssignees() {
    final users = getSortedUsers(apiService).whereNot((u) => u == userAll).toList()..insert(0, unassigned);
    return users;
  }

  List<AreaOrIteration> getAreasToShow() {
    final areas = apiService.workItemAreas;
    return areas[isEditing ? editingWorkItem!.fields.systemTeamProject : newWorkItemProject.name!] ?? [];
  }

  List<AreaOrIteration> getIterationsToShow() {
    final areas = apiService.workItemIterations;
    return areas[isEditing ? editingWorkItem!.fields.systemTeamProject : newWorkItemProject.name!] ?? [];
  }

  /// Gets all the fields for the selected work item type.
  Future<void> _getTypeFormFields() async {
    // refresh UI without any html editor and wait a bit to make the editors reinitialize correctly
    fieldsToShow = {};
    _refreshPage();
    await Future<void>.delayed(Duration(milliseconds: 50));

    formFields.clear();

    final projectName = editingWorkItem?.fields.systemTeamProject ?? newWorkItemProject.name!;

    final res = await apiService.getWorkItemTypeFields(
      projectName: projectName,
      workItemName: newWorkItemType.name,
    );

    if (res.isError) {
      OverlayService.snackbar('Could not get fields for type ${newWorkItemType.name}', isError: true);
      return;
    }

    fieldsToShow = res.data?.fields ?? <String, Set<WorkItemField>>{};
    allRules = res.data?.rules ?? {};

    for (final entry in fieldsToShow.entries) {
      for (final field in entry.value) {
        final refName = field.referenceName;
        formFields[refName] = _DynamicFieldData(required: field.required);

        if (!field.readOnly && field.defaultValue != null) {
          formFields[refName]!.controller.text = field.defaultValue!;
          formFields[refName]!.text = field.defaultValue!;
        }

        if (isEditing) {
          final text = editingWorkItem!.fields.jsonFields[refName]?.toString() ?? field.defaultValue ?? '';
          onFieldChanged(text, refName);
        }
      }
    }

    final htmlFieldsToShow = fieldsToShow.values.expand((f) => f).where((f) => f.type == 'html');
    for (final field in htmlFieldsToShow) {
      final formField = formFields[field.referenceName];
      formField?.editorGlobalKey = GlobalKey<State>();
      formField?.editorController = HtmlEditorController();

      if (isEditing) {
        formField?.editorInitialText =
            editingWorkItem!.fields.jsonFields[field.referenceName]?.toString() ?? field.defaultValue ?? '';
      }
    }

    final selectableFieldsToShow = fieldsToShow.values.expand((f) => f).where((f) => f.hasMeaningfulAllowedValues);
    for (final field in selectableFieldsToShow) {
      final formField = formFields[field.referenceName];
      formField?.popupMenuKey = GlobalKey<PopupMenuButtonState<dynamic>>();
    }

    _resetInitialFormFields();
    _checkRules();
  }

  void _checkRules() {
    for (final entry in fieldsToShow.entries) {
      for (final field in entry.value) {
        field
          ..readOnly = _checkIfIsReadOnly(field)
          ..required = _checkIfIsRequired(field);

        final refName = field.referenceName;

        if (formFields[refName] != null && field.readOnly) {
          // reset field to previous value
          final initialValue = _initialFormFields[refName];
          if (initialValue != null) {
            formFields[refName]!.text = initialValue.text;
            formFields[refName]!.controller.text = initialValue.text.formatted;
          }
        }
      }
    }
  }

  void onFieldChanged(String str, String fieldRefName) {
    final formField = formFields[fieldRefName];
    formField?.text = str;
    formField?.controller.text = str.formatted;

    _setHasChanged();

    _checkRules();
    _refreshPage();
  }

  String? fieldValidator(String? str, WorkItemField field) {
    if (str == null) return null;
    if (field.type == null) return null;

    if (str.isEmpty && !field.required) return null;

    if (str.isEmpty) return 'Fill this field';

    switch (field.type) {
      case 'double':
      case 'integer':
        return num.tryParse(str) != null ? null : 'Must be a number';
      default:
        return null;
    }
  }

  Future<void> setDateField(String fieldRefName) async {
    final date = await showDatePicker(
      context: AppRouter.rootNavigator!.context,
      initialDate: DateTime.tryParse(formFields[fieldRefName]?.text ?? '')?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (date == null) return;

    final dateMinutes = date.timeZoneOffset.inMinutes.abs() % 60;
    final dateHours = date.timeZoneOffset.inHours;
    final datePrefix = dateHours.isNegative ? '-' : '+';

    final dateText =
        '${date.toIso8601String()}$datePrefix${dateHours.abs().toString().padLeft(2, '0')}:${dateMinutes.toString().padLeft(2, '0')}';

    onFieldChanged(dateText, fieldRefName);

    _setHasChanged();
  }

  void showPopupMenu(String fieldRefName) {
    formFields[fieldRefName]?.popupMenuKey?.currentState?.showButtonMenu();
  }

  // TODO extract class RulesValidator
  // TODO handle rules on fields outside form (title, areaId, maybe iterationId and maybe assignedTo)
  // TODO show meaningful error (parsed from api response) (like 'The field Description is required/read-only)

  /// Checks whether this field should be read-only according to the rules.
  ///
  /// A rule can have a maximum of 2 conditions, and if they're all true, then
  /// the actions (maximum 10) will be applied.
  bool _checkIfIsReadOnly(WorkItemField field) {
    final rules = allRules[field.referenceName] ?? [];
    if (rules.isEmpty) return false;

    final makeReadOnlyActions = rules.where((r) => r.action == ActionType.makeReadOnly).toList();
    if (makeReadOnlyActions.isEmpty) return false;

    var isReadOnly = false;

    for (final rule in makeReadOnlyActions) {
      final conditions = rule.conditions;
      if (conditions.isEmpty) break;

      if (conditions.length == 1) {
        final cond = conditions.single;
        isReadOnly |= _checkSingleReadOnly(cond);
        continue;
      }

      // we have 2 conditions
      final firstCond = conditions.first;
      final secondCond = conditions.last;
      isReadOnly |= _checkSingleReadOnly(firstCond) && _checkSingleReadOnly(secondCond);
    }

    return isReadOnly;
  }

  /// Checks whether this field should be required according to the rules.
  ///
  /// A rule can have a maximum of 2 conditions, and if they're all true, then
  /// the actions (maximum 10) will be applied.
  // TODO make one method that takes [makeRequiredActions] or [makeReadOnlyActions] as input
  bool _checkIfIsRequired(WorkItemField field) {
    final rules = allRules[field.referenceName] ?? [];
    if (rules.isEmpty) return false;

    final makeRequiredActions = rules.where((r) => r.action == ActionType.makeRequired).toList();
    if (makeRequiredActions.isEmpty) return false;

    var isReadOnly = false;

    for (final rule in makeRequiredActions) {
      final conditions = rule.conditions;
      if (conditions.isEmpty) break;

      if (conditions.length == 1) {
        final cond = conditions.single;
        isReadOnly |= _checkSingleReadOnly(cond);
        continue;
      }

      // we have 2 conditions
      final firstCond = conditions.first;
      final secondCond = conditions.last;
      isReadOnly |= _checkSingleReadOnly(firstCond) && _checkSingleReadOnly(secondCond);
    }

    return isReadOnly;
  }

  String getFieldName(WorkItemField field) {
    final fieldName = field.name;
    final isReadOnly = field.readOnly;

    if (isReadOnly) {
      return '$fieldName (read-only)';
    }

    final isRequired = field.required;

    if (isRequired) {
      return '$fieldName *';
    }

    return fieldName;
  }

  bool _checkSingleReadOnly(Condition cond) {
    if (cond.conditionType == ConditionType.whenNotChanged &&
        cond.field == 'System.State' &&
        cond.value == null &&
        _initialWorkItemStatus?.name == newWorkItemStatus?.name) {
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
        _initialFormFields[cond.field]?.text.formatted != formFields[cond.field]?.text.formatted) {
      // rule on change field value
      return true;
    }

    if (cond.conditionType == ConditionType.whenNotChanged &&
        formFields[cond.field] != null &&
        cond.value == null &&
        _initialFormFields[cond.field]?.text.formatted == formFields[cond.field]?.text.formatted) {
      // rule on field value not changed
      return true;
    }

    if (cond.conditionType == ConditionType.whenWas &&
        cond.field == 'System.State' &&
        cond.value == _initialWorkItemStatus?.name &&
        isEditing) {
      // rule on change from state
      return true;
    }

    if (cond.conditionType == ConditionType.when &&
        cond.field == 'System.State' &&
        cond.value == newWorkItemStatus?.name &&
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

    if (cond.conditionType == ConditionType.whenNot &&
        cond.field == 'System.State' &&
        cond.value != newWorkItemStatus?.name) {
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

class _DynamicFieldData {
  _DynamicFieldData({required this.required});

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

extension on WorkItemField {
  bool get hasMeaningfulAllowedValues => allowedValues.where((v) => v != '<None>').isNotEmpty;
}
