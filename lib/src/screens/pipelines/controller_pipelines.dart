part of pipelines;

class _PipelinesController with FilterMixin {
  factory _PipelinesController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    return instance ??= _PipelinesController._(apiService, storageService, project);
  }

  _PipelinesController._(this.apiService, this.storageService, this.project);

  static _PipelinesController? instance;

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final pipelines = ValueNotifier<ApiResponse<List<Pipeline>?>?>(null);

  int get inProgressPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.inProgress).length ?? 0;
  int get queuedPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.notStarted).length ?? 0;

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

  List<Project> projects = [];

  late Project projectFilter = project ?? allProject;
  PipelineResult resultFilter = PipelineResult.all;
  PipelineStatus statusFilter = PipelineStatus.all;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    projects = [allProject, ...storageService.getChosenProjects()];
    await _getData();
  }

  Future<void> _getData() async {
    final now = DateTime.now();

    final res = await apiService.getRecentPipelines(
      project: projectFilter.name == userAll.displayName ? null : projectFilter,
      result: resultFilter,
      status: statusFilter,
      triggeredBy: userFilter.displayName == userAll.displayName ? null : userFilter.mailAddress,
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
    projectFilter = proj.name! == userAll.displayName ? allProject : proj;
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
    userFilter = userAll;

    init();
  }
}
