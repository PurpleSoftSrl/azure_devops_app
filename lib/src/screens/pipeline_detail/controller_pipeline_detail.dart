part of pipeline_detail;

class _PipelineDetailController with ShareMixin, AdsMixin, ApiErrorHelper {
  _PipelineDetailController._(this.args, this.api, this.ads) : visibilityKey = GlobalKey();

  final ({String project, int id}) args;
  final AzureApiService api;
  final AdsService ads;

  final buildDetail = ValueNotifier<ApiResponse<PipelineWithTimeline?>?>(null);

  final pipeStages = ValueNotifier<List<_Stage>?>(null);

  Timer? _timer;

  Pipeline get pipeline => buildDetail.value!.data!.pipeline;

  List<Approval> get pendingApprovals => pipeline.approvals.where((a) => a.isPending).toList();
  bool get hasPendingApprovals => pendingApprovals.isNotEmpty;

  bool get hasApprovals => pipeline.approvals.isNotEmpty;

  GlobalKey visibilityKey;
  var _hasStoppedTimer = false;

  void dispose() {
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> init() async {
    await _init();

    if (buildDetail.value?.data != null) {
      final pipeStatus = pipeline.status;

      // auto refresh page every 5 seconds until pipeline is completed
      if (pipeStatus == PipelineStatus.notStarted || pipeStatus == PipelineStatus.inProgress) {
        _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
          await _init();
          if (buildDetail.value?.data != null && pipeline.status == PipelineStatus.completed) {
            timer.cancel();
          }
        });
      }
    }
  }

  Future<void> _init() async {
    final res = await api.getPipeline(projectName: args.project, id: args.id);
    if (res.isError) {
      buildDetail.value = res;
      return;
    }

    final approvals = await api.getPipelineApprovals(pipeline: res.data!.pipeline);
    res.data!.pipeline.approvals = approvals.data ?? [];

    buildDetail.value = res;

    final realLogs = res.data!.timeline.where((r) => r.order < 1000);

    final stages = realLogs.where((r) => r.type == 'Stage').sorted((a, b) => a.order.compareTo(b.order));
    final phases = realLogs.where((r) => r.type == 'Phase').sorted((a, b) => a.order.compareTo(b.order));
    final jobs = realLogs.where((r) => r.type == 'Job').sorted((a, b) => a.order.compareTo(b.order));
    final tasks = realLogs.where((r) => r.type == 'Task').sorted((a, b) => a.order.compareTo(b.order));

    final timeline = <_Stage>[];

    for (final stage in stages) {
      timeline.add(
        _Stage(
          stage: stage,
          phases: phases
              .where((p) => p.parentId == stage.id)
              .map(
                (p) => _Phase(
                  phase: p,
                  jobs: jobs
                      .where((j) => j.parentId == p.id)
                      .map((j) => _Job(job: j, tasks: tasks.where((t) => t.parentId == j.id).toList()))
                      .toList(),
                ),
              )
              .toList(),
        ),
      );
    }

    pipeStages.value = timeline;
  }

  Future<void> getActionFromStatus() async {
    if (pipeline.status == PipelineStatus.completed) {
      await _rerunBuild();
    } else {
      await _cancelBuild();
    }
  }

  String getActionTextFromStatus() {
    return pipeline.status == PipelineStatus.completed ? 'Rerun pipeline' : 'Cancel pipeline';
  }

  IconData getActionIconFromStatus() {
    return pipeline.status == PipelineStatus.completed ? DevOpsIcons.running : DevOpsIcons.cancelled;
  }

  Future<void> _cancelBuild() async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to cancel this pipeline?',
    );
    if (!confirm) return;

    final res = await api.cancelPipeline(buildId: args.id, projectId: pipeline.project!.id!);

    if (res.isError) {
      return OverlayService.error('Build not canceled', description: 'Try again');
    }

    await showInterstitialAd(ads);

    AppRouter.pop();
  }

  Future<void> _rerunBuild() async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to rerun this pipeline?',
    );
    if (!confirm) return;

    final res = await api.rerunPipeline(
      definitionId: pipeline.definition!.id!,
      projectId: pipeline.project!.id!,
      branch: pipeline.sourceBranch!,
    );

    if (res.isError) {
      return OverlayService.error('Build not rerun', description: 'Try again');
    }

    await showInterstitialAd(ads);

    AppRouter.pop();
  }

  String getBuildWebUrl() {
    return '${api.basePath}/${pipeline.project!.name}/_build/results?buildId=${args.id}&view=results';
  }

  void shareBuild() {
    shareUrl(getBuildWebUrl());
  }

  Duration getQueueTime() {
    if (pipeline.startTime != null) {
      return pipeline.startTime!.difference(pipeline.queueTime!);
    }

    final now = DateTime.now();
    return now.difference(pipeline.queueTime!);
  }

  Duration getRunTime() {
    if (pipeline.finishTime != null) {
      return pipeline.finishTime!.difference(pipeline.startTime!);
    }

    final now = DateTime.now();
    return now.difference(pipeline.startTime!);
  }

  void goToProject() {
    AppRouter.goToProjectDetail(pipeline.project!.name!);
  }

  Future<void> goToRepo() async {
    if (pipeline.repository?.name == null) return;

    await AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: pipeline.project!.name!, repositoryName: pipeline.repository!.name!),
    );
  }

  void goToCommitDetail() {
    if (pipeline.repository?.name == null) return;

    AppRouter.goToCommitDetail(
      project: pipeline.project!.name!,
      repository: pipeline.repository!.name!,
      commitId: pipeline.triggerInfo!.ciSourceSha!,
    );
  }

  void seeLogs(Record t) {
    if (t.log == null) {
      OverlayService.error('Error', description: 'Logs not ready yet');
      return;
    }

    AppRouter.goToPipelineLogs((
      project: pipeline.project!.name!,
      pipelineId: pipeline.id!,
      taskId: t.id,
      parentTaskId: t.parentId!,
      logId: t.log!.id,
    ));
  }

  void visibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction <= 0 && _timer != null) {
      _hasStoppedTimer = true;
      _stopTimer();
    } else if (info.visibleFraction > 0 && _hasStoppedTimer) {
      init();
    }
  }

  void goToPreviousRuns() {
    AppRouter.goToPipelines(args: (definition: pipeline.definition!.id!, project: pipeline.project!, shortcut: null));
  }

  String getPendingApprovalText() {
    final length = pendingApprovals.length;
    return '$length approval${length > 1 ? 's' : ''} need${length > 1 ? '' : 's'} review before this run can continue';
  }

  void viewAllApprovals() {
    OverlayService.bottomsheet(
      title: 'Approvals',
      isScrollControlled: true,
      builder: (_) => _PendingApprovalsBottomSheet(
        approvals: pipeline.approvals,
        canApprove: (_) => false,
        isBlockedApprover: (_) => false,
        onApprove: (_) {},
        onDefer: (_) {},
        onReject: (_) {},
      ),
    );
  }

  void viewPendingApprovals() {
    OverlayService.bottomsheet(
      title: 'Pending approvals',
      isScrollControlled: true,
      builder: (_) => _PendingApprovalsBottomSheet(
        approvals: pendingApprovals,
        canApprove: _canApprove,
        isBlockedApprover: _isBlockedApprover,
        onApprove: _approveApproval,
        onDefer: _deferApproval,
        onReject: _rejectApproval,
      ),
    );
  }

  bool _canApprove(Approval approval) {
    final pendingStep = approval.steps.firstWhereOrNull((s) => s.isPending);
    if (pendingStep == null) return false;

    final userEmail = api.user!.emailAddress;

    return !_isBlockedApprover(approval) && (pendingStep.assignedApprover.uniqueName == userEmail);
  }

  bool _isBlockedApprover(Approval approval) {
    final pendingStep = approval.steps.firstWhereOrNull((s) => s.isPending);
    if (pendingStep == null) return false;

    final userEmail = api.user!.emailAddress;

    return approval.blockedApprovers.map((a) => a.uniqueName).contains(userEmail);
  }

  Future<void> _approveApproval(Approval approval) async {
    final conf = await OverlayService.confirm('Attention', description: 'Do you really want to approve this approval?');

    if (!conf) return;

    final res = await api.approvePipelineApproval(approval: approval, projectId: pipeline.project!.id!);

    if (!(res.data ?? false)) {
      final errorMessage = getErrorMessage(res.errorResponse!);
      return OverlayService.error('Error', description: 'Approval not approved.\n\n$errorMessage');
    }

    AppRouter.popRoute();

    await showInterstitialAd(ads, onDismiss: () => OverlayService.snackbar('Approval approved successfully'));
  }

  Future<void> _deferApproval(Approval approval) async {
    final deferredDateTime = await OverlayService.bottomsheet<DateTime>(
      title: 'Defer approval',
      isScrollControlled: true,
      builder: (_) => _DeferApprovalBottomSheet(),
    );
    if (deferredDateTime == null) return;

    final res = await api.approvePipelineApproval(
      approval: approval,
      projectId: pipeline.project!.id!,
      deferredTo: deferredDateTime,
    );

    if (!(res.data ?? false)) {
      final errorMessage = getErrorMessage(res.errorResponse!);
      return OverlayService.error('Error', description: 'Approval not deferred.\n\n$errorMessage');
    }

    AppRouter.popRoute();

    await showInterstitialAd(ads, onDismiss: () => OverlayService.snackbar('Approval deferred successfully'));
  }

  Future<void> _rejectApproval(Approval approval) async {
    final conf = await OverlayService.confirm('Attention', description: 'Do you really want to reject this approval?');

    if (!conf) return;

    final res = await api.rejectPipelineApproval(approval: approval, projectId: pipeline.project!.id!);

    if (!(res.data ?? false)) {
      final errorMessage = getErrorMessage(res.errorResponse!);
      return OverlayService.error('Error', description: 'Approval not rejected.\n\n$errorMessage');
    }

    AppRouter.popRoute();

    await showInterstitialAd(ads, onDismiss: () => OverlayService.snackbar('Approval rejected successfully'));
  }
}

class _Stage {
  _Stage({required this.stage, required this.phases});

  final Record stage;
  final List<_Phase> phases;
}

class _Phase {
  _Phase({required this.phase, required this.jobs});

  final Record phase;
  final List<_Job> jobs;
}

class _Job {
  _Job({required this.job, required this.tasks});

  final Record job;
  final List<Record> tasks;
}

extension on Record {
  String getRunTime() {
    if (startTime == null) return '';

    return (finishTime ?? DateTime.now()).timeDifference(startTime!);
  }
}
