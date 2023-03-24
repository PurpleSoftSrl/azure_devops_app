part of work_items;

class _WorkItemsController {
  factory _WorkItemsController({required AzureApiService apiService, required StorageService storageService}) {
    return instance ??= _WorkItemsController._(apiService, storageService);
  }

  _WorkItemsController._(this.apiService, this.storageService);

  static _WorkItemsController? instance;

  final AzureApiService apiService;

  final StorageService storageService;

  final workItems = ValueNotifier<ApiResponse<List<WorkItem>?>?>(null);

  final _workItemStateAll = 'All';

  late String statusFilter = _workItemStateAll;
  WorkItemType typeFilter = WorkItemType.all;

  final allProject = Project(
    id: '-1',
    name: 'All',
    description: '',
    url: '',
    state: '',
    revision: -1,
    visibility: '',
    lastUpdateTime: DateTime.now(),
  );

  late Project projectFilter = allProject;
  List<Project> projects = [];

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

  late GraphUser userFilter = _userNone;
  List<GraphUser> users = [];

  late List<WorkItemType> allWorkItemTypes = [typeFilter];

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    statusFilter = _workItemStateAll;
    typeFilter = WorkItemType.all;

    allWorkItemTypes = [typeFilter];

    users = apiService.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    projectFilter = allProject;
    projects = [allProject];

    final types = await apiService.getWorkItemTypes();
    if (!types.isError) {
      allWorkItemTypes.addAll(types.data!.values.expand((ts) => ts).toSet());
    }

    await _getData();

    projects.addAll(storageService.getChosenProjects());
  }

  void goToWorkItemDetail(WorkItem item) {
    AppRouter.goToWorkItemDetail(item);
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

  void filterByProject(Project proj) {
    workItems.value = null;
    projectFilter = proj.name == 'All' ? allProject : proj;
    _getData();
  }

  Future<void> _getData() async {
    final res = await apiService.getWorkItems();
    res.data?.sort((a, b) => b.changedDate.compareTo(a.changedDate));

    if (statusFilter == _workItemStateAll && typeFilter == WorkItemType.all && projectFilter == allProject) {
      workItems.value = res;
    } else {
      final filteredByTypeItems = typeFilter == WorkItemType.all
          ? res.data
          : res.data?.where((i) => i.workItemType == typeFilter.name).toList();

      final filteredByStatusItems = statusFilter == _workItemStateAll
          ? filteredByTypeItems
          : filteredByTypeItems?.where((i) => i.state == statusFilter);

      final filteredByProjectItems = projectFilter == allProject
          ? filteredByStatusItems
          : filteredByStatusItems?.where((i) => i.teamProject == projectFilter.name);

      workItems.value = ApiResponse.ok(filteredByProjectItems?.toList());
    }
  }

  void resetFilters() {
    workItems.value = null;
    init();
  }

  // ignore: long-method
  Future<void> createWorkItem() async {
    var newWorkItemProject = projects.firstWhereOrNull((p) => p.id != '-1') ?? allProject;

    var newWorkItemType = allWorkItemTypes.first;

    var newWorkItemAssignedTo = _userNone;
    var newWorkItemTitle = '';
    var newWorkItemDescription = '';

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
                        builder: (_, setState) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type'),
                            const SizedBox(
                              height: 5,
                            ),
                            FilterMenu<WorkItemType>(
                              title: 'Type',
                              values: allWorkItemTypes.where((t) => t.name != 'All').toList(),
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
                            Text('Project'),
                            const SizedBox(
                              height: 5,
                            ),
                            FilterMenu<Project>(
                              title: 'Project',
                              values: projects.where((p) => p != allProject).toList(),
                              currentFilter: newWorkItemProject,
                              onSelected: (p) {
                                setState(() {
                                  newWorkItemProject = p;
                                });
                              },
                              formatLabel: (p) => p.name!,
                              isDefaultFilter: newWorkItemProject == allProject,
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

    if (newWorkItemProject == allProject || newWorkItemType == WorkItemType.all || newWorkItemTitle.isEmpty) {
      return;
    }

    final res = await apiService.createWorkItem(
      projectName: newWorkItemProject.name!,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: newWorkItemAssignedTo.displayName == 'Assigned to' ? null : newWorkItemAssignedTo,
      description: newWorkItemDescription,
    );

    if (res.isError) {
      return OverlayService.error('Error', description: 'Work item not created');
    }

    await init();
  }
}
