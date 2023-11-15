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
      instance = _PipelinesController._(apiService, storageService, args);
    }

    instance ??= _PipelinesController._(apiService, storageService, args);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _PipelinesController._(this.apiService, this.storageService, this.args) {
    projectFilter = args?.project ?? projectAll;
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

  PipelineResult resultFilter = PipelineResult.all;
  PipelineStatus statusFilter = PipelineStatus.all;

  Timer? _timer;

  final visibilityKey = GlobalKey();
  var _hasStoppedTimer = false;

  void dispose() {
    _stopTimer();

    instance = null;
    _instances.remove(args.hashCode);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> init() async {
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

  Future<void> _getData() async {
    final now = DateTime.now();

    final res = await apiService.getRecentPipelines(
      project: projectFilter.name == projectAll.name ? null : projectFilter,
      definition: args?.definition,
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
    await AppRouter.goToPipelineDetail(id: pipeline.id!, project: pipeline.project!.name!);
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
    resultFilter = PipelineResult.all;
    statusFilter = PipelineStatus.all;
    userFilter = userAll;

    if (args?.definition == null) projectFilter = projectAll;

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
}
