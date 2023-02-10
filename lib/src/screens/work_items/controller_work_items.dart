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

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    statusFilter = _workItemStateAll;
    typeFilter = WorkItemType.all;

    projectFilter = allProject;
    projects = [allProject];

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
      final filteredByTypeItems =
          typeFilter == WorkItemType.all ? res.data : res.data?.where((i) => i.workItemType == typeFilter).toList();

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
}
