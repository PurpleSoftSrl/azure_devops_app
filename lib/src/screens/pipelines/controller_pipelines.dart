part of pipelines;

class _PipelinesController with FilterMixin {
  factory _PipelinesController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    // handle page already in memory with a different project filter
    if (_instances[project.hashCode] != null) {
      return _instances[project.hashCode]!;
    }

    if (instance != null && project?.id != instance!.project?.id) {
      instance = _PipelinesController._(apiService, storageService, project);
    }

    instance ??= _PipelinesController._(apiService, storageService, project);
    return _instances.putIfAbsent(project.hashCode, () => instance!);
  }

  _PipelinesController._(this.apiService, this.storageService, this.project) {
    projectFilter = project ?? projectAll;
  }

  static _PipelinesController? instance;
  static final Map<int, _PipelinesController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final pipelines = ValueNotifier<ApiResponse<List<Pipeline>?>?>(null);

  int get inProgressPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.inProgress).length ?? 0;
  int get queuedPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.notStarted).length ?? 0;

  PipelineResult resultFilter = PipelineResult.all;
  PipelineStatus statusFilter = PipelineStatus.all;

  void dispose() {
    instance = null;
    _instances.remove(project.hashCode);
  }

  Future<void> init() async {
    await _getData();
  }

  Future<void> _getData() async {
    final now = DateTime.now();

    final res = await apiService.getRecentPipelines(
      project: projectFilter.name == projectAll.name ? null : projectFilter,
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
    if (proj.id == projectFilter.id) return;

    pipelines.value = null;
    projectFilter = proj.name! == projectAll.name ? projectAll : proj;
    _getData();
  }

  void filterByResult(PipelineResult result) {
    if (result == resultFilter) return;

    pipelines.value = null;
    resultFilter = result;
    _getData();
  }

  void filterByStatus(PipelineStatus status) {
    if (status == statusFilter) return;

    pipelines.value = null;
    statusFilter = status;
    _getData();
  }

  void filterByUser(GraphUser u) {
    if (u.mailAddress == userFilter.mailAddress) return;

    pipelines.value = null;
    userFilter = u;
    _getData();
  }

  void resetFilters() {
    pipelines.value = null;
    projectFilter = projectAll;
    resultFilter = PipelineResult.all;
    statusFilter = PipelineStatus.all;
    userFilter = userAll;

    init();
  }
}
