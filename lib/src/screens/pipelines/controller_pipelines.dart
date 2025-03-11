part of pipelines;

class _PipelinesController with FilterMixin, ApiErrorHelper, AdsMixin {
  _PipelinesController._(this.api, this.storage, this.args, this.ads) {
    if (args?.project != null) projectsFilter = {args!.project!};
  }

  final AzureApiService api;
  final StorageService storage;
  final AdsService ads;
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
    storage: storage,
    organization: api.organization,
  );

  bool get isDefaultPipelineNamesFilter => pipelineNamesFilter.isEmpty;

  bool get showPipelineNamesFilter => getPipelineNames().isNotEmpty;

  /// Read/write filters from local storage only if user is not coming from project page or from shortcut
  bool get shouldPersistFilters => args?.project == null && !hasShortcut;

  bool get hasShortcut => args?.shortcut != null;

  void dispose() {
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> init() async {
    if (shouldPersistFilters) {
      _fillSavedFilters();
    } else if (hasShortcut) {
      _fillShortcutFilters();
    }

    await _getDataAndAds();

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

  Future<void> _getDataAndAds() async {
    await getNewNativeAds(ads);
    await _getData();
  }

  void _fillSavedFilters() {
    final savedFilters = filtersService.getPipelinesSavedFilters();
    _fillFilters(savedFilters);
  }

  void _fillShortcutFilters() {
    final savedFilters = filtersService.getPipelinesShortcut(args!.shortcut!.label);
    _fillFilters(savedFilters);
  }

  void _fillFilters(PipelinesFilters savedFilters) {
    if (savedFilters.projects.isNotEmpty) {
      projectsFilter = getProjects(storage).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.pipelines.isNotEmpty) {
      pipelineNamesFilter = savedFilters.pipelines;
    }

    if (savedFilters.triggeredBy.isNotEmpty) {
      usersFilter = getSortedUsers(api).where((p) => savedFilters.triggeredBy.contains(p.mailAddress)).toSet();
    }

    if (savedFilters.result.isNotEmpty) {
      resultFilter = PipelineResult.fromString(savedFilters.result.first);
    } else if (savedFilters.status.isNotEmpty) {
      statusFilter = PipelineStatus.fromString(savedFilters.status.first);
    }
  }

  Future<void> _getData() async {
    final now = DateTime.now();

    final res = await api.getRecentPipelines(
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      definition: args?.definition,
      result: resultFilter,
      status: statusFilter,
      triggeredBy: isDefaultUsersFilter ? null : usersFilter.map((u) => u.mailAddress ?? '').toSet(),
    );

    if (res.isError) {
      pipelines.value = res;
      if (res.errorResponse?.statusCode == 400) {
        // ignore: unawaited_futures, to refresh the page immediately
        _handleBadRequest(res.errorResponse!);
      }
      return;
    }

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

    final runningPipelines = pipes.where((p) => p.status == PipelineStatus.inProgress);

    if (runningPipelines.isNotEmpty) {
      final approvalsRes = await api.getPendingApprovals(pipelines: runningPipelines.toList());

      final approvalsByPipeline = groupBy(approvalsRes.data ?? <Approval>[], (a) => a.pipeline.owner.id);

      for (final approval in approvalsByPipeline.entries) {
        final pipeline = runningPipelines.firstWhereOrNull((p) => p.id == approval.key);
        if (pipeline != null) {
          pipeline.approvals = approval.value.where((a) => a.status == 'pending').toList();
        }
      }
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
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePipelinesProjectsFilter(projects.map((p) => p.name!).toSet());
    }
  }

  void filterByResult(PipelineResult result) {
    if (result == resultFilter) return;

    pipelines.value = null;
    resultFilter = result;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePipelinesResultFilter(result.stringValue);
    }
  }

  void filterByStatus(PipelineStatus status) {
    if (status == statusFilter) return;

    pipelines.value = null;
    statusFilter = status;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePipelinesStatusFilter(status.stringValue);
    }
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    pipelines.value = null;
    usersFilter = users;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePipelinesTriggeredByFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void filterByPipelines(Set<String> names) {
    if (names == pipelineNamesFilter) return;

    pipelines.value = null;
    pipelineNamesFilter = names;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePipelinesNamesFilter(names);
    }
  }

  void resetFilters() {
    pipelines.value = null;
    resultFilter = PipelineResult.all;
    statusFilter = PipelineStatus.all;
    usersFilter.clear();

    if (args?.definition == null) projectsFilter.clear();

    pipelineNamesFilter.clear();

    if (shouldPersistFilters) {
      filtersService.resetPipelinesFilters();
    }

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

  Future<void> saveFilters() async {
    final shortcutLabel = await OverlayService.formBottomsheet(title: 'Choose a name', label: 'Name');
    if (shortcutLabel == null) return;

    final res = filtersService.savePipelinesShortcut(
      shortcutLabel,
      filters: PipelinesFilters(
        projects: projectsFilter.map((p) => p.name!).toSet(),
        pipelines: pipelineNamesFilter,
        triggeredBy: usersFilter.map((u) => u.mailAddress!).toSet(),
        result: {if (resultFilter != PipelineResult.all) resultFilter.stringValue},
        status: {if (statusFilter != PipelineStatus.all) statusFilter.stringValue},
      ),
    );

    OverlayService.snackbar(res.message, isError: !res.result);
  }

  Future<void> _handleBadRequest(Response response) async {
    final error = getErrorMessageAndType(response);
    if (error.type == projectNotFoundException) {
      final deletedProject = parseProjectNotFoundName(error.msg);
      if (deletedProject != null) {
        final conf = await OverlayService.confirm(
          'Project not found',
          description:
              'It looks like the project "$deletedProject" does not exist anymore. Do you want to remove it from your selected projects?',
        );
        if (!conf) return;

        api.removeChosenProject(deletedProject);

        final updatedProjectFilter = {...projectsFilter}..removeWhere((p) => p.name == deletedProject);
        filterByProjects(updatedProjectFilter);
      }
    }
  }
}
