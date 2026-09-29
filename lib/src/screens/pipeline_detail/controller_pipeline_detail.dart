part of pipeline_detail;

class _PipelineDetailController with ShareMixin, AdsMixin, ApiErrorHelper {
  _PipelineDetailController._(this.args, this.api, this.ads) : visibilityKey = GlobalKey();

  final ({String project, int id}) args;
  final AzureApiService api;
  final AdsService ads;

  final buildDetail = ValueNotifier<ApiResponse<PipelineWithTimeline?>?>(null);

  final pipeStages = ValueNotifier<List<_Stage>?>(null);

  /// Graph descriptors identifying the current user as an approver (own descriptor + groups).
  Set<String> _approverDescriptors = {};

  Timer? _timer;

  Pipeline get pipeline => buildDetail.value!.data!.pipeline;

  Set<String> get _manualApprovalIds =>
      buildDetail.value?.data?.timeline
          .where((record) => record.type == 'Task' && record.task?.name == 'ManualValidation')
          .map((record) => record.identifier)
          .whereType<String>()
          .toSet() ??
      {};

  List<Approval> get _stageApprovals {
    final manualIds = _manualApprovalIds;
    return pipeline.approvals.where((a) => !manualIds.contains(a.id)).toList();
  }

  List<({Record task, Approval approval})> get pendingManualValidations {
    final data = buildDetail.value?.data;
    if (data == null) return [];

    return [
      for (final task in data.timeline)
        if (task.type == 'Task' && task.task?.name == 'ManualValidation' && task.state == TaskStatus.inProgress)
          if (data.pipeline.approvals.firstWhereOrNull((a) => a.id == task.identifier && a.isPending)
              case final approval?)
            (task: task, approval: approval),
    ];
  }

  List<Approval> get pendingApprovals {
    return _stageApprovals.where((a) => a.isPending).toList();
  }

  bool get hasPendingApprovals => pendingApprovals.isNotEmpty;

  bool get hasApprovals => _stageApprovals.isNotEmpty;

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

    if (approvals.data?.isNotEmpty ?? false) {
      final descriptors = await api.getCurrentUserApproverDescriptors();
      _approverDescriptors = descriptors.data ?? {};
    }

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
        approvals: _stageApprovals,
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

  void viewManualValidations([Record? task]) {
    final validations = pendingManualValidations.where((v) => task == null || v.task.id == task.id).toList();
    if (validations.isEmpty) return;

    OverlayService.bottomsheet(
      title: 'Manual validations',
      isScrollControlled: true,
      builder: (_) => _ManualValidationsBottomSheet(
        validations: validations,
        canAct: (approval) => !_isBlockedApprover(approval),
        onResume: (approval) => _actOnManualValidation(approval, resume: true),
        onReject: (approval) => _actOnManualValidation(approval, resume: false),
      ),
    );
  }

  Future<void> _actOnManualValidation(Approval approval, {required bool resume}) async {
    if (_manualActionInProgress || !pendingManualValidations.any((v) => v.approval.id == approval.id)) return;
    if (_isBlockedApprover(approval)) return;

    _manualActionInProgress = true;
    try {
      final verb = resume ? 'resume' : 'reject';
      final confirmed = await OverlayService.confirm(
        'Attention',
        description: 'Do you really want to $verb this manual validation?',
      );
      if (!confirmed) return;

      final current = pendingManualValidations.firstWhereOrNull((v) => v.approval.id == approval.id)?.approval;
      if (current == null || _isBlockedApprover(current)) return;

      final res = resume
          ? await api.approvePipelineApproval(approval: current, projectId: pipeline.project!.id!)
          : await api.rejectPipelineApproval(approval: current, projectId: pipeline.project!.id!);

      if (res.data != true) {
        final message = res.errorResponse == null ? 'Try again' : getErrorMessage(res.errorResponse!);
        await OverlayService.error(
          'Manual validation not ${resume ? 'resumed' : 'rejected'}',
          description: message.isEmpty
              ? 'It may have timed out or you may not have permission. Refresh and try again.'
              : message,
        );
        return;
      }

      AppRouter.popRoute();
      await _init();
      OverlayService.snackbar('Manual validation ${resume ? 'resumed' : 'rejected'} successfully');
    } finally {
      _manualActionInProgress = false;
    }
  }

  bool _manualActionInProgress = false;

  bool _canApprove(Approval approval) {
    if (_isBlockedApprover(approval)) return false;

    return approval.steps.any((s) => s.isPending && _isCurrentUser(s.assignedApprover));
  }

  bool _isBlockedApprover(Approval approval) => approval.blockedApprovers.any(_isCurrentUser);

  /// Whether [approver] represents the current user, either directly or via a group membership.
  bool _isCurrentUser(AssignedApprover approver) {
    final user = api.user!;
    final email = user.emailAddress?.toLowerCase();

    return (email != null && approver.uniqueName.toLowerCase() == email) ||
        (approver.id.isNotEmpty && approver.id == user.id) ||
        (approver.descriptor.isNotEmpty && _approverDescriptors.contains(approver.descriptor));
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
