part of pipelines;

class _PipelinesController {
  factory _PipelinesController({required AzureApiService apiService}) {
    return instance ??= _PipelinesController._(apiService);
  }

  _PipelinesController._(this.apiService);

  static _PipelinesController? instance;

  final AzureApiService apiService;

  final pipelines = ValueNotifier<ApiResponse<List<Pipeline>?>?>(null);

  int get inProgressPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.inProgress).length ?? 0;
  int get queuedPipelines => pipelines.value?.data?.where((b) => b.status == PipelineStatus.notStarted).length ?? 0;

  PipelineResult resultFilter = PipelineResult.all;
  PipelineStatus statusFilter = PipelineStatus.all;

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
    resultFilter = PipelineResult.all;
    statusFilter = PipelineStatus.all;

    userFilter = _userAll;

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

    pipelines.value = ApiResponse.ok(pipes);
  }

  Future<void> goToPipelineDetail(Pipeline pipeline) async {
    await AppRouter.goToPipelineDetail(pipeline);
    await init();
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
    init();
  }
}
