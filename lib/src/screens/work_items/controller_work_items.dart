part of work_items;

class _WorkItemsController with FilterMixin {
  factory _WorkItemsController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    // handle page already in memory with a different project filter
    if (_instances[project.hashCode] != null) {
      return _instances[project.hashCode]!;
    }

    if (instance != null && project?.id != instance!.project?.id) {
      instance = _WorkItemsController._(apiService, storageService, project);
    }

    instance ??= _WorkItemsController._(apiService, storageService, project);
    return _instances.putIfAbsent(project.hashCode, () => instance!);
  }

  _WorkItemsController._(this.apiService, this.storageService, this.project) {
    projectFilter = project ?? projectAll;
  }

  static _WorkItemsController? instance;
  static final Map<int, _WorkItemsController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final workItems = ValueNotifier<ApiResponse<List<WorkItem>?>?>(null);

  final _workItemStateAll = 'All';

  late String statusFilter = _workItemStateAll;
  WorkItemType typeFilter = WorkItemType.all;

  Map<String, List<WorkItemType>> allProjectsWorkItemTypes = {};
  late List<WorkItemType> allWorkItemTypes = [typeFilter];

  void dispose() {
    instance = null;
    _instances.remove(project.hashCode);
  }

  Future<void> init() async {
    allWorkItemTypes = [typeFilter];

    final types = await apiService.getWorkItemTypes();
    if (!types.isError) {
      allWorkItemTypes.addAll(types.data!.values.expand((ts) => ts).toSet());
      allProjectsWorkItemTypes = types.data!;
    }

    await _getData();
  }

  Future<void> goToWorkItemDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(item);
    await _getData();
  }

  void filterByProject(Project proj) {
    workItems.value = null;
    projectFilter = proj.name == projectAll.name ? projectAll : proj;
    _getData();
  }

  void filterByStatus(String state) {
    workItems.value = null;
    statusFilter = state;
    _getData();
  }

  void filterByType(WorkItemType type) {
    workItems.value = null;
    typeFilter = type;
    _getData();
  }

  void filterByUser(GraphUser user) {
    workItems.value = null;
    userFilter = user;
    _getData();
  }

  Future<void> _getData() async {
    final res = await apiService.getWorkItems(
      project: projectFilter == projectAll ? null : projectFilter,
      type: typeFilter == WorkItemType.all ? null : typeFilter,
      status: statusFilter == _workItemStateAll ? null : statusFilter,
      assignedTo: userFilter == userAll ? null : userFilter,
    );
    workItems.value = res;
  }

  void resetFilters() {
    workItems.value = null;
    statusFilter = _workItemStateAll;
    typeFilter = WorkItemType.all;
    projectFilter = projectAll;
    userFilter = userAll;

    init();
  }

  // ignore: long-method
  Future<void> createWorkItem() async {
    var newWorkItemProject = getProjects(storageService).firstWhereOrNull((p) => p.id != '-1') ?? projectAll;

    var newWorkItemType = allWorkItemTypes.first;

    var newWorkItemAssignedTo = userAll;
    var newWorkItemTitle = '';
    var newWorkItemDescription = '';

    var projectWorkItemTypes = allWorkItemTypes;

    final titleFieldKey = GlobalKey<FormFieldState<dynamic>>();

    await OverlayService.bottomsheet(
      isScrollControlled: true,
      title: 'Create a new work item',
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
                  'Create a new work item',
                  style: context.textTheme.titleLarge,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      StatefulBuilder(
                        builder: (_, setState) {
                          if (newWorkItemProject != projectAll) {
                            projectWorkItemTypes = allProjectsWorkItemTypes[newWorkItemProject.name]!
                                .where((t) => t.name != WorkItemType.all.name)
                                .toList();

                            if (!projectWorkItemTypes.contains(newWorkItemType)) {
                              newWorkItemType = projectWorkItemTypes.first;
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Project'),
                              const SizedBox(
                                height: 5,
                              ),
                              FilterMenu<Project>.bottomsheet(
                                title: 'Project',
                                values: getProjects(storageService).where((p) => p != projectAll).toList(),
                                currentFilter: newWorkItemProject,
                                onSelected: (p) {
                                  setState(() => newWorkItemProject = p);
                                },
                                formatLabel: (p) => p.name!,
                                isDefaultFilter: newWorkItemProject == projectAll,
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
                                values: projectWorkItemTypes,
                                currentFilter: newWorkItemType,
                                formatLabel: (t) => t.name,
                                onSelected: (f) {
                                  setState(() {
                                    newWorkItemType = f;
                                  });
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
                              FilterMenu<GraphUser>.bottomsheet(
                                title: 'Assigned to',
                                values: getSortedUsers(apiService)
                                    .whereNot((u) => u.displayName == userAll.displayName)
                                    .toList(),
                                currentFilter: newWorkItemAssignedTo,
                                onSelected: (u) {
                                  setState(() {
                                    newWorkItemAssignedTo = u;
                                  });
                                },
                                formatLabel: (u) => u.displayName!,
                                isDefaultFilter: newWorkItemAssignedTo.displayName == userAll.displayName,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      DevOpsFormField(
                        onChanged: (value) => newWorkItemTitle = value,
                        label: 'Work item title',
                        formFieldKey: titleFieldKey,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      DevOpsFormField(
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

    if (newWorkItemProject == projectAll || newWorkItemType == WorkItemType.all || newWorkItemTitle.isEmpty) {
      return;
    }

    final res = await apiService.createWorkItem(
      projectName: newWorkItemProject.name!,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: newWorkItemAssignedTo.displayName == userAll.displayName ? null : newWorkItemAssignedTo,
      description: newWorkItemDescription,
    );

    if (res.isError) {
      return OverlayService.error('Error', description: 'Work item not created');
    }

    await init();
  }
}
