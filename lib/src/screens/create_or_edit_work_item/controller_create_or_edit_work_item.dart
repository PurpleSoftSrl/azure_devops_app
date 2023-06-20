// ignore_for_file: use_setters_to_change_properties

part of create_or_edit_work_item;

class _CreateOrEditWorkItemController with FilterMixin {
  factory _CreateOrEditWorkItemController({
    required AzureApiService apiService,
    required ({int? id, String? project}) args,
    required StorageService storageService,
  }) {
    return instance ??= _CreateOrEditWorkItemController._(apiService, args, storageService);
  }

  _CreateOrEditWorkItemController._(this.apiService, this.args, this.storageService);

  static _CreateOrEditWorkItemController? instance;

  final AzureApiService apiService;
  final StorageService storageService;
  final ({int? id, String? project}) args;

  final hasChanged = ValueNotifier<ApiResponse<bool>?>(null);

  final editorController = HtmlEditorController();

  // Used to ensure editor is visible when keyboard is opened
  final editorGlobalKey = GlobalKey<State>();

  final titleFieldKey = GlobalKey<FormFieldState<dynamic>>();

  List<WorkItemType> allWorkItemTypes = [WorkItemType.all];
  Map<String, List<WorkItemType>> allProjectsWorkItemTypes = {};
  List<WorkItemState> allWorkItemStates = [WorkItemState.all];

  late List<WorkItemType> projectWorkItemTypes = allWorkItemTypes;

  String newWorkItemTitle = '';
  String newWorkItemDescription = '';
  late GraphUser newWorkItemAssignedTo = userAll;
  late WorkItemType newWorkItemType = allWorkItemTypes.first;
  late Project newWorkItemProject = getProjects(storageService).firstWhereOrNull((p) => p.id != '-1') ?? projectAll;

  // used only in edit mode
  WorkItemState? newWorkItemStatus;

  bool get isEditing => args.id != null;
  WorkItem? editingWorkItem;

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

    _refreshPage();
  }

  void _setFields(WorkItem item) {
    editingWorkItem = item;
    final fields = item.fields;
    projectWorkItemTypes = apiService.workItemTypes[fields.systemTeamProject] ?? <WorkItemType>[];
    allWorkItemStates = apiService.workItemStates[fields.systemTeamProject]?[fields.systemWorkItemType] ?? [];

    newWorkItemTitle = fields.systemTitle;
    newWorkItemDescription = fields.systemDescription ?? '';
    newWorkItemAssignedTo =
        getSortedUsers(apiService).firstWhereOrNull((u) => u.mailAddress == fields.systemAssignedTo?.uniqueName) ??
            userAll;
    newWorkItemType = projectWorkItemTypes.firstWhereOrNull((t) => t.name == fields.systemWorkItemType) ??
        WorkItemType(
          name: fields.systemWorkItemType,
          referenceName: fields.systemWorkItemType,
          color: '',
          isDisabled: false,
          icon: '',
        );
    newWorkItemStatus = apiService.workItemStates[fields.systemTeamProject]?[fields.systemWorkItemType]
        ?.firstWhereOrNull((s) => s.name == fields.systemState);
  }

  void setType(WorkItemType type) {
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
    _setHasChanged();
  }

  void setProject(Project project) {
    if (project == newWorkItemProject) return;

    newWorkItemProject = project;

    if (!isEditing && newWorkItemProject != projectAll) {
      projectWorkItemTypes =
          allProjectsWorkItemTypes[newWorkItemProject.name]?.where((t) => t != WorkItemType.all).toList() ?? [];

      if (!projectWorkItemTypes.contains(newWorkItemType)) {
        newWorkItemType = projectWorkItemTypes.first;
      }
    }

    _setHasChanged();
  }

  void setAssignee(GraphUser assignee) {
    if (assignee == newWorkItemAssignedTo) return;

    newWorkItemAssignedTo = assignee;
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
    if (!titleFieldKey.currentState!.validate()) return;

    newWorkItemDescription = await editorController.getText();

    final errorMessage = _checkRequiredFields();
    if (errorMessage != null) return OverlayService.snackbar(errorMessage, isError: true);

    final res = isEditing ? await _editWorkItem() : await _createWorkItem();

    if (res.isError) {
      return OverlayService.error('Error', description: 'Work item not ${isEditing ? 'edited' : 'created'}');
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

  Future<ApiResponse<WorkItem>> _editWorkItem() async {
    final res = await apiService.editWorkItem(
      projectName: args.project!,
      id: args.id!,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: newWorkItemAssignedTo.displayName == userAll.displayName ? null : newWorkItemAssignedTo,
      description: newWorkItemDescription,
      status: newWorkItemStatus?.name,
    );
    return res;
  }

  Future<ApiResponse<WorkItem>> _createWorkItem() async {
    final res = await apiService.createWorkItem(
      projectName: newWorkItemProject.name!,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: newWorkItemAssignedTo.displayName == userAll.displayName ? null : newWorkItemAssignedTo,
      description: newWorkItemDescription,
    );
    return res;
  }

  /// Resets editor's height and scrolls the page to make it fully visible.
  /// The delay is to wait for the keyboard to show.
  void ensureEditorIsVisible() {
    Timer(Duration(milliseconds: 500), () {
      editorController.resetHeight();
      final ctx = editorGlobalKey.currentContext;
      if (ctx == null) return;

      Scrollable.of(ctx).position.ensureVisible(
            ctx.findRenderObject()!,
            duration: Duration(milliseconds: 250),
          );
    });
  }

  Future<void> addMention(GraphUser u) async {
    final res = await apiService.getUserToMention(email: u.mailAddress!);
    if (res.isError || res.data == null) {
      return OverlayService.snackbar('Could not find user', isError: true);
    }

    // remove `(me)` from user name if it's me
    final name = u.mailAddress == apiService.user!.emailAddress ? apiService.user!.displayName : u.displayName;
    final mention = '<a href="#" data-vss-mention="version:2.0,${res.data}">@$name</a>';
    editorController.insertHtml(mention);
  }
}
