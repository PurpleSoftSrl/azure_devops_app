part of work_item_detail;

class _WorkItemDetailController {
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
      instance = _WorkItemDetailController._(item, apiService, forceRefresh: true, storageService);
    }

    instance ??= _WorkItemDetailController._(item, apiService, storageService);
    return _instances.putIfAbsent(item.hashCode, () => instance!);
  }

  _WorkItemDetailController._(this.item, this.apiService, this.storageService, {bool forceRefresh = false}) {
    if (forceRefresh) init();
  }

  static _WorkItemDetailController? instance;

  static final Map<int, _WorkItemDetailController> _instances = {};

  final WorkItem item;

  final AzureApiService apiService;

  final StorageService storageService;

  final itemDetail = ValueNotifier<ApiResponse<WorkItemDetail?>?>(null);

  String get itemWebUrl => '${apiService.basePath}/${item.teamProject}/_workitems/edit/${item.id}';

  final _userNone = GraphUser(
    subjectKind: '',
    domain: '',
    principalName: '',
    mailAddress: '',
    origin: '',
    originId: '',
    displayName: 'Assigned to',
    links: null,
    url: '',
    descriptor: '',
    metaType: '',
    directoryAlias: '',
  );

  List<GraphUser> users = [];

  List<WorkItemStatus> statuses = [];

  void dispose() {
    instance = null;
    _instances.remove(item.hashCode);
  }

  Future<void> init() async {
    final res = await apiService.getWorkItemDetail(projectName: item.teamProject, workItemId: item.id);
    itemDetail.value = res;

    users = apiService.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    await _getStatuses(item.workItemType);
  }

  Future<void> _getStatuses(WorkItemType workItemType) async {
    final statusesRes =
        await apiService.getWorkItemStatuses(projectName: item.teamProject, type: workItemType.toString());
    statuses = statusesRes.data ?? [];
  }

  void shareWorkItem() {
    Share.share(itemWebUrl);
  }

  void goToProject() {
    AppRouter.goToProjectDetail(item.teamProject);
  }

  // ignore: long-method
  Future<void> editWorkItem() async {
    final fields = itemDetail.value!.data!.fields;

    var newWorkItemStatus = fields.systemState;
    var newWorkItemType = WorkItemType.fromString(fields.systemWorkItemType);
    var newWorkItemAssignedTo =
        users.firstWhereOrNull((u) => u.displayName == fields.systemAssignedTo?.displayName) ?? _userNone;
    var newWorkItemTitle = fields.systemTitle;
    var newWorkItemDescription = fields.systemDescription ?? '';

    var shouldEdit = false;

    final titleFieldKey = GlobalKey<FormFieldState<dynamic>>();

    await showModalBottomSheet(
      context: AppRouter.rootNavigator!.context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
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
                            Text('Status'),
                            const SizedBox(
                              height: 5,
                            ),
                            FilterMenu<String>(
                              title: 'Status',
                              values: statuses.map((s) => s.name).toList(),
                              currentFilter: newWorkItemStatus,
                              onSelected: (f) {
                                setState(() {
                                  newWorkItemStatus = f;
                                });
                              },
                              isDefaultFilter: false,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text('Type'),
                            const SizedBox(
                              height: 5,
                            ),
                            FilterMenu<WorkItemType>(
                              title: 'Type',
                              values: WorkItemType.values.where((t) => t != WorkItemType.all).toList(),
                              currentFilter: newWorkItemType,
                              onSelected: (f) async {
                                newWorkItemType = f;
                                await _getStatuses(newWorkItemType);
                                if (!statuses.map((e) => e.name).contains(newWorkItemStatus)) {
                                  // change status if new type doesn't support current status
                                  newWorkItemStatus = statuses.firstOrNull?.name ?? newWorkItemStatus;
                                }

                                setState(() => true);
                              },
                              isDefaultFilter: newWorkItemType == WorkItemType.all,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text('Assigned to'),
                            const SizedBox(
                              height: 5,
                            ),
                            FilterMenu<GraphUser>.user(
                              title: 'Assigned to',
                              values: users,
                              currentFilter: newWorkItemAssignedTo,
                              onSelected: (u) {
                                setState(() {
                                  newWorkItemAssignedTo = u;
                                });
                              },
                              formatLabel: (u) => u.displayName!,
                              isDefaultFilter: newWorkItemAssignedTo.displayName == 'Assigned to',
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

    if (newWorkItemType.toString() == fields.systemWorkItemType &&
        newWorkItemStatus == fields.systemState &&
        newWorkItemTitle == fields.systemTitle &&
        newWorkItemAssignedTo.displayName == fields.systemAssignedTo?.displayName &&
        newWorkItemDescription == fields.systemDescription) {
      return;
    }

    final res = await apiService.editWorkItem(
      projectName: item.teamProject,
      id: item.id,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: newWorkItemAssignedTo.displayName == 'Assigned to' ? null : newWorkItemAssignedTo,
      description: newWorkItemDescription,
      status: newWorkItemStatus,
    );

    if (res.isError) {
      return AlertService.error('Error', description: 'Work item not edited');
    }

    await init();
  }

  Future<void> deleteWorkItem() async {
    final conf = await AlertService.confirm('Attention', description: 'Do you really want to delete this work item?');
    if (!conf) return;

    final res = await apiService.deleteWorkItem(projectName: item.teamProject, id: item.id);
    if (!(res.data ?? false)) {
      return AlertService.error('Error', description: 'Work item not deleted');
    }

    AppRouter.pop();
  }
}
