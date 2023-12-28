part of pipelines;

class _PipelinesController with FilterMixin {
  factory _PipelinesController({
    required AzureApiService apiService,
    required StorageService storageService,
    PipelinesArgs? args,
  }) {
    // handle page already in memory with a different filter
    if (_instances[args.hashCode] != null) {
      return _instances[args.hashCode]!;
    }

    if (instance != null && args != instance!.args) {
      instance = null;
    }

    instance ??= _PipelinesController._(apiService, storageService, args);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _PipelinesController._(this.apiService, this.storageService, this.args) {
    if (args?.project != null) projectsFilter = {args!.project!};
  }

  static _PipelinesController? instance;
  static final Map<int, _PipelinesController> _instances = {};

  final AzureApiService apiService; 
  final StorageService storageService;
  final PipelinesArgs? args;

  final pipelines = ValueNotifier<ApiResponse<List<Pipeline>?>?>(null);

  int get inProgressPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.inProgress).length ?? 0;
  int get queuedPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.notStarted).length ?? 0;
  int get cancellingPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.cancelling).length ?? 0;

  Set<String> pipelineNamesFilter = {};
  PipelineResult resultFilter = PipelineResult.all;
  PipelineStatus statusFilter = PipelineStatus.all;

  Timer? _timer;

  final visibilityKey = GlobalKey();
  var _hasStoppedTimer = false;

  late final filtersService = FiltersService(
    storageService: storageService,
    organization: apiService.organization,
  );

  bool get isDefaultPipelineNamesFilter => pipelineNamesFilter.isEmpty;

  bool get showPipelineNamesFilter => getPipelineNames().isNotEmpty;

  void dispose() {
    _stopTimer();

    instance = null;
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> init() async {
    _fillSavedFilters();

    await _getData();

    if (pipelines.value != null) {
      final shouldRefresh = inProgressPipelines > 0 || queuedPipelines > 0 || cancellingPipelines > 0;

      // auto refresh page every 5 seconds until all pipelines are completed
      if (shouldRefresh && !(_timer?.isActive ?? false)) {
        _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
          await _getData();
          final shouldRefresh = inProgressPipelines > 0 || queuedPipelines > 0 || cancellingPipelines > 0;
          if (!shouldRefresh) {
            timer.cancel();
          }
        });
      }
    }
  }

  void _fillSavedFilters() {
    final savedFilters = filtersService.getPipelinesSavedFilters();

    if (savedFilters.projects.isNotEmpty) {
      projectsFilter = getProjects(storageService).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.pipelines.isNotEmpty) {
      pipelineNamesFilter = savedFilters.pipelines;
    }

    if (savedFilters.triggeredBy.isNotEmpty) {
      usersFilter = getSortedUsers(apiService).where((p) => savedFilters.triggeredBy.contains(p.mailAddress)).toSet();
    }

    if (savedFilters.result.isNotEmpty) {
      resultFilter = PipelineResult.fromString(savedFilters.result.first);
    } else if (savedFilters.status.isNotEmpty) {
      statusFilter = PipelineStatus.fromString(savedFilters.status.first);
    }
  }

  Future<void> _getData() async {
    final now = DateTime.now();

    final res = await apiService.getRecentPipelines(
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      definition: args?.definition,
      result: resultFilter,
      status: statusFilter,
      triggeredBy: isDefaultUsersFilter ? null : usersFilter.map((u) => u.mailAddress ?? '').toSet(),
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

    if (!isDefaultPipelineNamesFilter) {
      pipes = pipes.where((p) => pipelineNamesFilter.contains(p.definition?.name)).toList();
    }

    pipelines.value = res.copyWith(data: pipes);
  }

  Future<void> goToPipelineDetail(Pipeline pipeline) async {
    await AppRouter.goToPipelineDetail(id: pipeline.id!, project: pipeline.project!.name!);
    await init();
  }

  void filterByProjects(Set<Project> projects) {
    if (projects == projectsFilter) return;

    pipelines.value = null;
    projectsFilter = projects;
    _getData();

    filtersService.savePipelinesProjectsFilter(projects.map((p) => p.name!).toSet());
  }

  void filterByResult(PipelineResult result) {
    if (result == resultFilter) return;

    pipelines.value = null;
    resultFilter = result;
    _getData();

    filtersService.savePipelinesResultFilter(result.stringValue);
  }

  void filterByStatus(PipelineStatus status) {
    if (status == statusFilter) return;

    pipelines.value = null;
    statusFilter = status;
    _getData();

    filtersService.savePipelinesStatusFilter(status.stringValue);
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    pipelines.value = null;
    usersFilter = users;
    _getData();

    filtersService.savePipelinesTriggeredByFilter(users.map((p) => p.mailAddress!).toSet());
  }

  void filterByPipelines(Set<String> names) {
    if (names == pipelineNamesFilter) return;

    pipelines.value = null;
    pipelineNamesFilter = names;
    _getData();
    
    filtersService.savePipelinesNamesFilter(names);
  }

  void resetFilters() {
    pipelines.value = null;
    resultFilter = PipelineResult.all;
    statusFilter = PipelineStatus.all;
    usersFilter.clear();

    if (args?.definition == null) projectsFilter.clear();

    pipelineNamesFilter.clear();

    filtersService.resetPipelinesFilters();

    init();
  }

  void visibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction <= 0 && _timer != null) {
      _hasStoppedTimer = true;
      _stopTimer();
    } else if (info.visibleFraction > 0 && _hasStoppedTimer) {
      init();
    }
  }

  List<String> getPipelineNames() {
    final pipelines = this.pipelines.value?.data;
    if (pipelines == null) return [];

    return pipelines
        .where((p) => p.definition?.name != p.repository?.name)
        .map((p) => p.definition?.name)
        .whereType<String>()
        .toSet()
        .sortedBy((s) => s.toLowerCase());
  }
}
