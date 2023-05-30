part of work_item_detail;

class _WorkItemDetailController with ShareMixin, FilterMixin {
  factory _WorkItemDetailController({
    required WorkItem item,
    required AzureApiService apiService,
    required StorageService storageService,
  }) {
    // handle page already in memory with a different work item
    if (_instances[item.hashCode] != null) {
      return _instances[item.hashCode]!;
    }

    if (instance != null && instance!.item != item) {
      instance = _WorkItemDetailController._(item, apiService, storageService);
    }

    instance ??= _WorkItemDetailController._(item, apiService, storageService);
    return _instances.putIfAbsent(item.hashCode, () => instance!);
  }

  _WorkItemDetailController._(this.item, this.apiService, this.storageService);

  static _WorkItemDetailController? instance;

  static final Map<int, _WorkItemDetailController> _instances = {};

  final WorkItem item;

  final AzureApiService apiService;

  final StorageService storageService;

  final itemDetail = ValueNotifier<ApiResponse<WorkItemDetail?>?>(null);

  String get itemWebUrl => '${apiService.basePath}/${item.fields.systemTeamProject}/_workitems/edit/${item.id}';

  List<WorkItemState> statuses = [];

  List<WorkItemUpdate> updates = [];
  final showUpdatesReversed = ValueNotifier(true);

  void dispose() {
    instance = null;
    _instances.remove(item.hashCode);
  }

  Future<void> init() async {
    final res = await apiService.getWorkItemDetail(projectName: item.fields.systemTeamProject, workItemId: item.id);

    await _getUpdates();
    itemDetail.value = res;
  }

  Future<void> _getUpdates() async {
    final res = await apiService.getWorkItemUpdates(projectName: item.fields.systemTeamProject, workItemId: item.id);
    updates = res.data ?? [];
  }

  void toggleShowUpdatesReversed() {
    showUpdatesReversed.value = !showUpdatesReversed.value;
  }

  void shareWorkItem() {
    shareUrl(itemWebUrl);
  }

  void goToProject() {
    AppRouter.goToProjectDetail(item.fields.systemTeamProject);
  }

  // ignore: long-method
  Future<void> editWorkItem() async {
    final fields = itemDetail.value!.data!.fields;

    final projectWorkItemTypes = apiService.workItemTypes[fields.systemTeamProject] ?? <WorkItemType>[];

    var newWorkItemStatus = apiService.workItemStates[fields.systemTeamProject]?[fields.systemWorkItemType]
        ?.firstWhereOrNull((s) => s.name == fields.systemState);

    var newWorkItemType = projectWorkItemTypes.firstWhereOrNull((t) => t.name == fields.systemWorkItemType) ??
        WorkItemType(
          name: fields.systemWorkItemType,
          referenceName: fields.systemWorkItemType,
          color: '',
          isDisabled: false,
          customization: '',
          description: '',
          icon: '',
          url: '',
        );

    statuses = apiService.workItemStates[fields.systemTeamProject]![newWorkItemType.name] ?? [];

    var newWorkItemAssignedTo =
        getSortedUsers(apiService).firstWhereOrNull((u) => u.mailAddress == fields.systemAssignedTo?.uniqueName) ??
            userAll;

    var newWorkItemTitle = fields.systemTitle;
    var newWorkItemDescription = fields.systemDescription ?? '';

    var shouldEdit = false;

    final titleFieldKey = GlobalKey<FormFieldState<dynamic>>();

    await OverlayService.bottomsheet(
      isScrollControlled: true,
      title: 'Edit work item',
      builder: (context) => Container(
        height: context.height * .9,
        decoration: BoxDecoration(
          color: context.colorScheme.background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Scaffold(
            body: Column(
              children: [
                Text(
                  'Edit work item',
                  style: context.textTheme.titleLarge,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      StatefulBuilder(
                        builder: (_, setState) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (newWorkItemStatus != null) ...[
                              Text('Status'),
                              const SizedBox(
                                height: 5,
                              ),
                              FilterMenu<WorkItemState>(
                                title: 'Status',
                                values: statuses,
                                currentFilter: newWorkItemStatus!,
                                formatLabel: (t) => t.name,
                                onSelected: (f) {
                                  setState(() => newWorkItemStatus = f);
                                },
                                isDefaultFilter: false,
                                widgetBuilder: (s) => WorkItemStateFilterWidget(state: s),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                            if (item.canBeChanged) ...[
                              Text('Type'),
                              const SizedBox(
                                height: 5,
                              ),
                              FilterMenu<WorkItemType>(
                                title: 'Type',
                                values: projectWorkItemTypes,
                                currentFilter: newWorkItemType,
                                formatLabel: (t) => t.name,
                                onSelected: (f) async {
                                  newWorkItemType = f;
                                  statuses =
                                      apiService.workItemStates[fields.systemTeamProject]![newWorkItemType.name] ?? [];
                                  if (!statuses.map((e) => e.name).contains(newWorkItemStatus)) {
                                    // change status if new type doesn't support current status
                                    newWorkItemStatus = statuses.firstOrNull ?? newWorkItemStatus;
                                  }

                                  setState(() => true);
                                },
                                isDefaultFilter: newWorkItemType == WorkItemType.all,
                                widgetBuilder: (t) => WorkItemTypeFilter(type: t),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                            Text('Assigned to'),
                            const SizedBox(
                              height: 5,
                            ),
                            FilterMenu<GraphUser>(
                              title: 'Assigned to',
                              values: getSortedUsers(apiService, withUserAll: false),
                              currentFilter: newWorkItemAssignedTo,
                              onSelected: (u) {
                                setState(() => newWorkItemAssignedTo = u);
                              },
                              formatLabel: (u) => u.displayName!,
                              isDefaultFilter: newWorkItemAssignedTo.displayName == userAll.displayName,
                              widgetBuilder: (u) => UserFilterWidget(user: u),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      DevOpsFormField(
                        initialValue: newWorkItemTitle,
                        onChanged: (value) => newWorkItemTitle = value,
                        label: 'Work item title',
                        formFieldKey: titleFieldKey,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      DevOpsFormField(
                        initialValue: newWorkItemDescription,
                        onChanged: (value) => newWorkItemDescription = value,
                        label: 'Work item description',
                        maxLines: 3,
                        onFieldSubmitted: AppRouter.popRoute,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      LoadingButton(
                        onPressed: () {
                          if (titleFieldKey.currentState!.validate()) {
                            shouldEdit = true;
                            AppRouter.popRoute();
                          }
                        },
                        text: 'Confirm',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!shouldEdit) return;

    if (newWorkItemType.name == fields.systemWorkItemType &&
        (newWorkItemStatus?.name ?? '') == fields.systemState &&
        newWorkItemTitle == fields.systemTitle &&
        newWorkItemAssignedTo.displayName == (fields.systemAssignedTo?.displayName ?? userAll.displayName) &&
        newWorkItemDescription == (fields.systemDescription ?? '')) {
      return;
    }

    final res = await apiService.editWorkItem(
      projectName: item.fields.systemTeamProject,
      id: item.id,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: newWorkItemAssignedTo.displayName == userAll.displayName ? null : newWorkItemAssignedTo,
      description: newWorkItemDescription,
      status: newWorkItemStatus?.name,
    );

    if (res.isError) {
      return OverlayService.error('Error', description: 'Work item not edited');
    }

    await init();
  }

  Future<void> deleteWorkItem() async {
    final conf = await OverlayService.confirm('Attention', description: 'Do you really want to delete this work item?');
    if (!conf) return;

    final res = await apiService.deleteWorkItem(projectName: item.fields.systemTeamProject, id: item.id);
    if (!(res.data ?? false)) {
      return OverlayService.error('Error', description: 'Work item not deleted');
    }

    AppRouter.pop();
  }
}
