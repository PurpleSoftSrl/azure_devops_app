part of pipelines;

class _PipelinesController {
  factory _PipelinesController({required AzureApiService apiService, required StorageService storageService}) {
    return instance ??= _PipelinesController._(apiService, storageService);
  }

  _PipelinesController._(this.apiService, this.storageService);

  static _PipelinesController? instance;

  final AzureApiService apiService;
  final StorageService storageService;

  final pipelines = ValueNotifier<ApiResponse<List<Pipeline>?>?>(null);

  int get inProgressPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.inProgress).length ?? 0;
  int get queuedPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.notStarted).length ?? 0;

  PipelineResult resultFilter = PipelineResult.all;
  PipelineStatus statusFilter = PipelineStatus.all;

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

  final _userAll = GraphUser(
    subjectKind: '',
    domain: '',
    principalName: '',
    mailAddress: '',
    origin: '',
    originId: '',
    displayName: 'All',
    links: null,
    url: '',
    descriptor: '',
    metaType: '',
    directoryAlias: '',
  );

  late GraphUser userFilter = _userAll;
  List<GraphUser> users = [];

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    projects = [allProject, ...storageService.getChosenProjects()];

    users = apiService.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    users.insert(0, _userAll);

    await _getData();
  }

  Future<void> _getData() async {
    final now = DateTime.now();

    final res = await apiService.getRecentPipelines(
      project: projectFilter.name == 'All' ? null : projectFilter,
      result: resultFilter,
      status: statusFilter,
      triggeredBy: userFilter.displayName == 'All' ? null : userFilter.mailAddress,
    );

    var pipes = res.data ?? [];

    // sort by start date. Pipelines in progress go first, then queued pipelines, and finally all the completed pipelines.
    pipes = pipes
      ..sort(
        (a, b) {
          final statusOrder = a.status!.order.compareTo(b.status.order);
          return statusOrder != 0 ? statusOrder : (b.startTime ?? now).compareTo(a.startTime ?? now);
        },
      );

    pipes = pipes.take(100).toList();

    pipelines.value = res.copyWith(data: pipes);
  }

  Future<void> goToPipelineDetail(Pipeline pipeline) async {
    await AppRouter.goToPipelineDetail(pipeline);
    await init();
  }

  void filterByProject(Project proj) {
    pipelines.value = null;
    projectFilter = proj.name! == 'All' ? allProject : proj;
    _getData();
  }

  void filterByResult(PipelineResult result) {
    pipelines.value = null;
    resultFilter = result;
    _getData();
  }

  void filterByStatus(PipelineStatus status) {
    pipelines.value = null;
    statusFilter = status;
    _getData();
  }

  void filterByUser(GraphUser u) {
    pipelines.value = null;
    userFilter = u;
    _getData();
  }

  void resetFilters() {
    pipelines.value = null;
    projectFilter = allProject;
    resultFilter = PipelineResult.all;
    statusFilter = PipelineStatus.all;
    userFilter = _userAll;

    init();
  }
}
