// ignore_for_file: use_setters_to_change_properties

part of create_or_edit_work_item;

class _CreateOrEditWorkItemController with FilterMixin, AppLogger {
  _CreateOrEditWorkItemController._(this.apiService, this.args, this.storageService) {
    if (args.project != null) {
      newWorkItemProject = getProjects(storageService).firstWhereOrNull((p) => p.name == args.project) ?? projectAll;
    }
    if (args.area != null) newWorkItemArea = AreaOrIteration.onlyPath(path: args.area!);
    if (args.iteration != null) newWorkItemIteration = AreaOrIteration.onlyPath(path: args.iteration!);
  }

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
  Map<String, List<String>> allTransitions = {};

  late List<WorkItemType> projectWorkItemTypes = allWorkItemTypes;

  String newWorkItemTitle = '';
  String newWorkItemDescription = '';

  final unassigned = GraphUser(displayName: 'Unassigned');
  late GraphUser newWorkItemAssignedTo = unassigned;
  late WorkItemType newWorkItemType = allWorkItemTypes.first;
  late Project newWorkItemProject = projectAll;

  // Used only in edit mode
  WorkItemState? newWorkItemState;

  /// Used to compare current state to initial one for rules validation
  WorkItemState? _initialWorkItemState;

  AreaOrIteration? newWorkItemArea;
  AreaOrIteration? newWorkItemIteration;

  /// Tags available for the project
  final _projectTags = ValueNotifier<Set<String>?>(null);

  /// Tags added to this work item
  Set<String> _newWorkItemTags = {};

  List<LinkType> _linkTypes = [];
  Set<WorkItemLink> _initialWorkItemLinks = {};

  /// Links added to this work item
  Set<WorkItemLink> _newWorkItemLinks = {};

  bool get isEditing => args.id != null;
  WorkItem? editingWorkItem;

  /// Data used to read/write each field. The keys are fields' reference names.
  final formFields = <String, DynamicFieldData>{};

  /// Used to compare current fields values to initial ones for rules validation
  Map<String, DynamicFieldData> _initialFormFields = {};

  // Used to show loader while api call to get fields is in progress because it can be slow
  final isGettingFields = ValueNotifier<bool>(false);

  Future<void> init() async {
    final linkTypesRes = await apiService.getWorkItemLinkTypes();
    _linkTypes = (linkTypesRes.data ?? []).sortedBy((t) => t.name);

    if (isEditing) {
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
    }

    if (args.project != null) {
      await setProject(newWorkItemProject, force: true);
    } else if (newWorkItemType != WorkItemType.all) {
      await _getTypeFormFields();
    }

    _refreshPage();
  }

  void _setFields(WorkItem item) {
    editingWorkItem = item;
    final fields = item.fields;
    final project = fields.systemTeamProject;
    final workItemType = fields.systemWorkItemType;

    projectWorkItemTypes = apiService.workItemTypes[project] ?? <WorkItemType>[];
    allWorkItemStates = _getTransitionableStates(project: project, workItemType: workItemType);

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

    _initialWorkItemState = newWorkItemState =
        apiService.workItemStates[project]?[workItemType]?.firstWhereOrNull((s) => s.name == fields.systemState) ??
            WorkItemState(
              id: '',
              name: fields.systemState,
              color: 'FFFFFF',
            );

    newWorkItemArea = AreaOrIteration.onlyPath(path: fields.systemAreaPath);
    newWorkItemIteration = AreaOrIteration.onlyPath(path: fields.systemIterationPath);

    if (fields.systemTags != null) {
      _newWorkItemTags = fields.systemTags!.split(';').map((t) => t.trim()).toSet();
    }

    if (item.workItemLinks.isNotEmpty) {
      _newWorkItemLinks = _getWorkItemLinks(item);
      _initialWorkItemLinks = {..._newWorkItemLinks};
    }
  }

  Future<void> setType(WorkItemType type) async {
    if (type == newWorkItemType) return;

    newWorkItemType = type;

    if (isEditing) {
      final project = editingWorkItem!.fields.systemTeamProject;
      final workItemType = newWorkItemType.name;
      allWorkItemStates = _getTransitionableStates(project: project, workItemType: workItemType);
      if (!allWorkItemStates.contains(newWorkItemState)) {
        // change status if new type doesn't support current status
        newWorkItemState = allWorkItemStates.firstOrNull ?? newWorkItemState;
      }
    }

    await _getTypeFormFields();

    _setHasChanged();
  }

  Future<void> setProject(Project project, {bool force = false}) async {
    if (project == newWorkItemProject && !force) return;

    newWorkItemProject = project;

    if (!isEditing && newWorkItemProject != projectAll) {
      projectWorkItemTypes =
          allProjectsWorkItemTypes[newWorkItemProject.name]?.where((t) => t != WorkItemType.all).toList() ?? [];

      if (!projectWorkItemTypes.contains(newWorkItemType) && projectWorkItemTypes.isNotEmpty) {
        newWorkItemType = projectWorkItemTypes.first;
      }
    }

    if (newWorkItemType != WorkItemType.all) await _getTypeFormFields();

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
    if (state == newWorkItemState) return;

    newWorkItemState = state;
    _setHasChanged();

    allWorkItemStates = _getTransitionableStates(project: args.project!, workItemType: newWorkItemType.name);

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

      final responseBody = res.errorResponse?.body ?? '';

      if (isInherited) {
        if (responseBody.isEmpty) {
          description += '\nInherited processes are not fully supported yet.';
        } else {
          final apiErrorMessage = jsonDecode(responseBody) as Map<String, dynamic>;
          final msg = apiErrorMessage['customProperties']?['ErrorMessage'] as String? ?? '';
          final firstMsg = msg.isEmpty ? '' : msg.substring(msg.indexOf(':') + 1).split('.').first;

          description += '\n$firstMsg';
          if (msg.contains('ReadOnly')) {
            description += ', the field is read-only.';
          } else if (msg.contains('Required')) {
            description += ', the field is required.';
          }
        }
      }

      if (responseBody.isNotEmpty) {
        final apiErrorMessage = jsonDecode(responseBody) as Map<String, dynamic>;
        final type = apiErrorMessage['typeKey'] as String? ?? '';
        if (['WorkItemLinkAddExtraParentException', 'WorkItemLinkCircularException'].contains(type)) {
          final msg = apiErrorMessage['message'] as String? ?? '';
          description += '\n${msg.split(':').lastOrNull?.trim()}';
        }
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
      return;
    }

    _resetInitialStateAndFormFields();
    final itemRes = await apiService.getWorkItemDetail(projectName: args.project!, workItemId: args.id!);
    final item = itemRes.data?.item;
    if (item == null) return;

    _newWorkItemLinks = _getWorkItemLinks(item);
    _initialWorkItemLinks = {..._newWorkItemLinks};

    // update fields again because api might change them, especially html fields
    for (final field in item.fields.jsonFields.entries) {
      final fieldData = formFields[field.key];
      if (fieldData == null) continue;

      final text = field.value?.toString() ?? '';
      fieldData.text = text;
      fieldData.controller.text = text.formatted;
      if (fieldData.editorController != null) {
        _trySetText(fieldData, text);
      }

      _initialFormFields[field.key] = fieldData;
    }
  }

  Set<WorkItemLink> _getWorkItemLinks(WorkItem item) =>
      item.workItemLinks.map((l) => l.toWorkItemLink(index: item.workItemLinks.indexOf(l))).toSet();

  void _showFormValidationError(String fieldName) {
    OverlayService.snackbar("Field '$fieldName' is required", isError: true);
  }

  /// When the user navigates to this page, and after each confirmed change,
  /// we have to reset [_initialWorkItemState] and [_initialFormFields] to restart rules validation from current state.
  void _resetInitialStateAndFormFields() {
    _initialWorkItemState = newWorkItemState;

    _initialFormFields = {
      for (final field in formFields.entries)
        field.key: DynamicFieldData(required: field.value.required)
          ..controller = field.value.controller
          ..text = field.value.controller.text.formatted
          ..editorController = field.value.editorController
          ..editorGlobalKey = field.value.editorGlobalKey
          ..editorInitialText = field.value.editorInitialText
          ..formFieldKey = field.value.formFieldKey
          ..popupMenuKey = field.value.popupMenuKey
          ..text = field.value.text,
    };

    if (isEditing) {
      allWorkItemStates =
          _getTransitionableStates(project: newWorkItemProject.name!, workItemType: newWorkItemType.name);
    }

    _checkRules();
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
      state: newWorkItemState?.name,
      area: newWorkItemArea,
      iteration: newWorkItemIteration,
      tags: _newWorkItemTags.toList(),
      links: _newWorkItemLinks.toList(),
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
      tags: _newWorkItemTags.toList(),
      links: _newWorkItemLinks.toList(),
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

    isGettingFields.value = true;

    final res = await apiService.getWorkItemTypeFields(
      projectName: projectName,
      workItemName: newWorkItemType.name,
    );

    isGettingFields.value = false;

    if (res.isError) {
      OverlayService.snackbar('Could not get fields for type ${newWorkItemType.name}', isError: true);
      return;
    }

    fieldsToShow = res.data?.fields ?? <String, Set<WorkItemField>>{};
    allRules = res.data?.rules ?? {};
    allTransitions = res.data?.transitions ?? {};

    allWorkItemStates = _getTransitionableStates(project: projectName, workItemType: newWorkItemType.name);

    // Init [formFields] so that we can [_checkRules] before writing anything into them.
    // This way we can avoid writing defaultValues into readOnly fields.
    for (final entry in fieldsToShow.entries) {
      for (final field in entry.value) {
        final refName = field.referenceName;
        formFields[refName] = DynamicFieldData(required: field.required);
      }
    }

    _checkRules();

    for (final entry in fieldsToShow.entries) {
      for (final field in entry.value) {
        final refName = field.referenceName;

        if (field.defaultValue != null && !field.readOnly) {
          formFields[refName]!.controller.text = field.defaultValue!;
          formFields[refName]!.text = field.defaultValue!;
        }

        if (isEditing) {
          // write already filled fields with values coming from api or their default value
          final alreadyFilledValue = editingWorkItem!.fields.jsonFields[refName];

          final String text;
          if (field.isIdentity) {
            if (alreadyFilledValue != null) {
              final user = GraphUser.fromJson(alreadyFilledValue as Map<String, dynamic>);
              text = user.displayName ?? user.mailAddress ?? '';
            } else {
              text = '';
            }
          } else {
            text = alreadyFilledValue?.toString() ?? (field.readOnly ? '' : field.defaultValue) ?? '';
          }

          onFieldChanged(text, refName, checkRules: false);
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

    _resetInitialStateAndFormFields();
  }

  void _checkRules() {
    final checker = RulesChecker(
      allRules: allRules,
      initialFormFields: _initialFormFields,
      formFields: formFields,
      isEditing: isEditing,
      initialState: _initialWorkItemState,
      state: newWorkItemState,
    );

    for (final entry in fieldsToShow.entries) {
      for (final field in entry.value) {
        final rules = checker.checkRules(field);
        field
          ..readOnly = rules.readOnly || rules.makeEmpty
          ..required = field.alwaysRequired || rules.required;

        final refName = field.referenceName;

        if (formFields[refName] != null && field.readOnly) {
          // reset field to previous value if it's editing mode, otherwise set it to empty string
          final initialValue = _initialFormFields[refName];
          if (initialValue != null) {
            final fieldData = formFields[refName]!;

            final text = isEditing ? initialValue.text : '';
            fieldData.text = text;
            fieldData.controller.text = text.formatted;

            if (fieldData.editorController != null) {
              _trySetText(fieldData, text);
            }
          }
        }

        if (formFields[refName] != null && rules.makeEmpty) {
          // make field value empty
          formFields[refName]!.text = '';
          formFields[refName]!.controller.text = '';
        }
      }
    }

    final disallowedStates = checker.getDisallowedStates();

    if (disallowedStates.isNotEmpty) {
      allWorkItemStates.removeWhere((s) => disallowedStates.contains(s.name));
    }
  }

  /// Uses a try-catch block to avoid exceptions when entering the page because the editor is still loading
  void _trySetText(DynamicFieldData fieldData, String text) {
    try {
      fieldData.editorController!.setText(text);
    } catch (e) {
      // ignore
    }
  }

  void onFieldChanged(String str, String fieldRefName, {bool checkRules = true}) {
    final formField = formFields[fieldRefName];
    formField?.text = str;
    formField?.controller.text = str.formatted;

    _setHasChanged();

    if (checkRules) _checkRules();

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

  List<WorkItemState> _getTransitionableStates({required String project, required String workItemType}) {
    final allStates = apiService.workItemStates[project]?[workItemType] ?? [];

    if (newWorkItemState == null) return allStates;

    final currentTransitionableStates = allTransitions[newWorkItemState!.name] ?? [];

    if (currentTransitionableStates.isEmpty) return allStates;

    return allStates.where((state) => currentTransitionableStates.contains(state.name)).toList();
  }

  List<GraphUser> searchAssignee(String query) {
    final loweredQuery = query.toLowerCase().trim();
    final users = getAssignees();
    return users.where((u) => u.displayName != null && u.displayName!.toLowerCase().contains(loweredQuery)).toList();
  }

  void addTag() {
    // ignore: unawaited_futures, reason: to show a loader inside the bottomsheet while getting tags
    _getProjectTags();

    OverlayService.bottomsheet(
      title: 'Add tags',
      heightPercentage: .7,
      isScrollControlled: true,
      builder: (context) => _AddTagBottomsheet(
        projectTags: _projectTags,
        addExistingTag: _addExistingTag,
        addNewTag: _addNewTag,
        workItemTags: _newWorkItemTags,
      ),
    );
  }

  Future<void> addLink() async {
    var hasConfirmed = false;
    final hasChanged = ValueNotifier<bool>(false);

    final formKey = GlobalKey<FormState>();

    final addedLink = WorkItemLink.withIndexOnly(index: _newWorkItemLinks.length);

    await OverlayService.bottomsheet(
      title: 'Add link',
      heightPercentage: .9,
      isScrollControlled: true,
      topRight: ValueListenableBuilder<bool>(
        valueListenable: hasChanged,
        builder: (context, changed, __) => SizedBox(
          width: 80,
          height: 20,
          child: !changed
              ? Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: AppRouter.popRoute,
                    child: Icon(Icons.close),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;

                    hasConfirmed = true;
                    AppRouter.popRoute();
                  },
                  style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                  child: Text(
                    'Confirm',
                    style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.primary),
                  ),
                ),
        ),
      ),
      builder: (context) => _AddLinkBottomsheet(
        hasChanged: hasChanged,
        linkTypes: _linkTypes,
        getWorkItems: _getWorkItemsToLink,
        formKey: formKey,
        addedLink: addedLink,
      ),
    );

    if (!hasConfirmed || addedLink.linkTypeReferenceName.isEmpty || addedLink.linkedWorkItemId <= 0) return;

    _addLink(addedLink);
  }

  Future<List<WorkItem>> _getWorkItemsToLink(String query) async {
    final queryId = int.tryParse(query);

    final loweredQuery = query.toLowerCase().trim();

    if (loweredQuery.isEmpty && queryId == null) return [];

    final itemsRes = await apiService.getWorkItems(
      title: queryId == null ? loweredQuery : null,
      id: queryId,
    );

    final workItems = itemsRes.data ?? [];

    return workItems.take(100).sorted((a, b) => b.id.compareTo(a.id));
  }

  Future<void> _getProjectTags() {
    return apiService.getProjectTags(projectName: newWorkItemProject.name!).then((res) {
      if (res.isError) {
        return OverlayService.snackbar('Could not get tags for project ${newWorkItemProject.name}', isError: true);
      }

      _projectTags.value = {
        if (_projectTags.value != null) ..._projectTags.value!,
        ...res.data!.map((t) => t.name).toSet(),
      };
    });
  }

  void _addExistingTag(String tag) {
    if (_newWorkItemTags.contains(tag)) {
      _newWorkItemTags.remove(tag);
    } else {
      _newWorkItemTags.add(tag);
    }

    _projectTags.value = {..._projectTags.value!};
    _setHasChanged();
  }

  bool _addNewTag(String tagToAdd) {
    if (tagToAdd.isEmpty) return false;

    if (_projectTags.value!.contains(tagToAdd)) {
      _addExistingTag(tagToAdd);
    } else {
      _newWorkItemTags.add(tagToAdd);
      _projectTags.value = {..._projectTags.value!, tagToAdd};
    }

    _setHasChanged();

    return true;
  }

  void removeTag(String tag) {
    _newWorkItemTags.remove(tag);
    _setHasChanged();
  }

  void _addLink(WorkItemLink link) {
    _newWorkItemLinks.add(link);
    _setHasChanged();
  }

  void removeLink(WorkItemLink link) {
    if (_initialWorkItemLinks.contains(link)) {
      link.isDeleted = true;
    } else {
      _newWorkItemLinks.remove(link);
    }

    _setHasChanged();
  }
}

extension on WorkItemField {
  bool get hasMeaningfulAllowedValues => allowedValues.where((v) => v != '<None>').isNotEmpty;
}
