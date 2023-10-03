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

  Map<String, Set<WorkItemField>> fieldsToShow = {};

  late List<WorkItemType> projectWorkItemTypes = allWorkItemTypes;

  String newWorkItemTitle = '';
  String newWorkItemDescription = '';

  final unassigned = GraphUser(displayName: 'Unassigned');
  late GraphUser newWorkItemAssignedTo = unassigned;
  late WorkItemType newWorkItemType = allWorkItemTypes.first;
  late Project newWorkItemProject = getProjects(storageService).firstWhereOrNull((p) => p.id != '-1') ?? projectAll;

  // used only in edit mode
  WorkItemState? newWorkItemStatus;

  AreaOrIteration? newWorkItemArea;
  AreaOrIteration? newWorkItemIteration;

  bool get isEditing => args.id != null;
  WorkItem? editingWorkItem;

  /// {field.referenceName: data}
  final dynamicFields = <String, _DynamicFieldData>{};

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
    projectWorkItemTypes = apiService.workItemTypes[fields.systemTeamProject] ?? <WorkItemType>[];
    allWorkItemStates = apiService.workItemStates[fields.systemTeamProject]?[fields.systemWorkItemType] ?? [];

    newWorkItemTitle = fields.systemTitle;
    newWorkItemDescription = fields.systemDescription ?? '';
    if (fields.systemAssignedTo != null) {
      newWorkItemAssignedTo =
          getSortedUsers(apiService).firstWhereOrNull((u) => u.mailAddress == fields.systemAssignedTo?.uniqueName) ??
              unassigned;
    }
    newWorkItemType = projectWorkItemTypes.firstWhereOrNull((t) => t.name == fields.systemWorkItemType) ??
        WorkItemType(
          name: fields.systemWorkItemType,
          referenceName: fields.systemWorkItemType,
          isDisabled: false,
          icon: '',
          states: [],
        );
    newWorkItemStatus = apiService.workItemStates[fields.systemTeamProject]?[fields.systemWorkItemType]
            ?.firstWhereOrNull((s) => s.name == fields.systemState) ??
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
      allWorkItemStates =
          apiService.workItemStates[editingWorkItem!.fields.systemTeamProject]![newWorkItemType.name] ?? [];
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
    for (final key in dynamicFields.entries) {
      final state = key.value.formFieldKey.currentState;
      if (state == null) continue;

      if (!state.validate()) return;
    }

    if (!titleFieldKey.currentState!.validate()) return;

    final htmlFieldsToShow = fieldsToShow.values.expand((f) => f).where((f) => f.type == 'html');
    for (final field in htmlFieldsToShow) {
      final text = await dynamicFields[field.referenceName]?.editorController?.getText() ?? '';
      dynamicFields[field.referenceName]!.text = text;
    }

    final textFieldsToShow = fieldsToShow.values.expand((f) => f).where((f) => f.type != 'html');
    for (final field in textFieldsToShow) {
      final text = dynamicFields[field.referenceName]?.controller.text ?? '';
      dynamicFields[field.referenceName]!.text = text;
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

    if (!isEditing) AppRouter.pop();
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
      dynamicFields: {for (final field in dynamicFields.entries) field.key: field.value.text},
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
      dynamicFields: {for (final field in dynamicFields.entries) field.key: field.value.text},
    );
    return res;
  }

  /// Resets editor's height and scrolls the page to make it fully visible.
  /// The delay is to wait for the keyboard to show.
  void ensureEditorIsVisible(String fieldRefName) {
    Timer(Duration(milliseconds: 500), () {
      dynamicFields[fieldRefName]?.editorController?.resetHeight();
      final ctx = dynamicFields[fieldRefName]?.editorGlobalKey?.currentContext;
      if (ctx == null) return;

      Scrollable.of(ctx).position.ensureVisible(
            ctx.findRenderObject()!,
            duration: Duration(milliseconds: 250),
          );
    });
  }

  Future<void> addMention(GraphUser u, String fieldRefName) async {
    final res = await apiService.getUserToMention(email: u.mailAddress!);
    if (res.isError || res.data == null) {
      return OverlayService.snackbar('Could not find user', isError: true);
    }

    // remove `(me)` from user name if it's me
    final name = u.mailAddress == apiService.user!.emailAddress ? apiService.user!.displayName : u.displayName;
    final mention = '<a href="#" data-vss-mention="version:2.0,${res.data}">@$name</a>';
    dynamicFields[fieldRefName]?.editorController?.insertHtml(mention);
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

  Future<void> _getTypeFormFields() async {
    // refresh UI without any html editor and wait a bit to make the editors reinitialize correctly
    fieldsToShow = {};
    _setHasChanged();
    await Future<void>.delayed(Duration(milliseconds: 50));

    dynamicFields.clear();

    final projectName = editingWorkItem?.fields.systemTeamProject ?? newWorkItemProject.name!;

    final res = await apiService.getWorkItemTypeFields(
      projectName: projectName,
      workItemName: newWorkItemType.name,
      workItemRefName: newWorkItemType.referenceName,
    );

    fieldsToShow = res.data ?? <String, Set<WorkItemField>>{};

    for (final entry in fieldsToShow.entries) {
      for (final field in entry.value) {
        dynamicFields[field.referenceName] = _DynamicFieldData(required: field.required);

        if (field.defaultValue != null) {
          dynamicFields[field.referenceName]!.controller.text = field.defaultValue!;
        }
        if (isEditing) {
          dynamicFields[field.referenceName]!.controller.text =
              editingWorkItem!.fields.jsonFields[field.referenceName]?.toString() ?? field.defaultValue ?? '';
        }
      }
    }

    final htmlFieldsToShow = fieldsToShow.values.expand((f) => f).where((f) => f.type == 'html');

    for (final field in htmlFieldsToShow) {
      dynamicFields[field.referenceName]?.editorGlobalKey = GlobalKey<State>();
      dynamicFields[field.referenceName]?.editorController = HtmlEditorController();

      if (isEditing) {
        dynamicFields[field.referenceName]!.editorInitialText =
            editingWorkItem!.fields.jsonFields[field.referenceName]?.toString() ?? field.defaultValue ?? '';
      }
    }
  }

  void onFieldChanged(String str, String fieldRefName) {
    dynamicFields[fieldRefName]!.text = str;
    dynamicFields[fieldRefName]!.controller.text = str;
  }

  String? fieldValidator(String? str, WorkItemField field) {
    if (str == null) return null;
    if (field.type == null) return null;

    if (str.isEmpty && !field.required) return null;

    if (str.isEmpty) return 'Fill this field';

    switch (field.type) {
      case 'double':
      case 'int':
        return num.tryParse(str) != null ? null : 'Must be a number';
      case 'dateTime':
        return DateTime.tryParse(str) != null ? null : 'Must be a valid date';
      default:
        return null;
    }
  }

  Future<void> setDateField(String fieldRefName) async {
    final date = await showDatePicker(
      context: AppRouter.rootNavigator!.context,
      initialDate: DateTime.tryParse(dynamicFields[fieldRefName]?.text ?? '')?.toLocal() ?? DateTime.now(),
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

  final bool required;
}
