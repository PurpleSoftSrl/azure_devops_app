part of pipeline_detail;

class _PipelineDetailController with ShareMixin {
  factory _PipelineDetailController({required ({String project, int id}) args, required AzureApiService apiService}) {
    // handle page already in memory with a different build
    if (_instances[args.hashCode] != null) {
      return _instances[args.hashCode]!;
    }

    if (instance != null && args.id != instance!.args.id) {
      instance = _PipelineDetailController._(args, apiService);
    }

    instance ??= _PipelineDetailController._(args, apiService);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _PipelineDetailController._(this.args, this.apiService);

  static _PipelineDetailController? instance;

  static final Map<int, _PipelineDetailController> _instances = {};

  final ({String project, int id}) args;
  final AzureApiService apiService;

  final buildDetail = ValueNotifier<ApiResponse<PipelineWithTimeline?>?>(null);

  final pipeStages = ValueNotifier<List<_Stage>?>(null);

  Timer? _timer;

  Pipeline get pipeline => buildDetail.value!.data!.pipeline;

  void dispose() {
    _timer?.cancel();
    _timer = null;

    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    await _init();

    if (buildDetail.value?.data != null) {
      final pipeStatus = pipeline.status;

      // auto refresh page every 5 seconds until pipeline is completed
      if (pipeStatus == PipelineStatus.notStarted || pipeStatus == PipelineStatus.inProgress) {
        _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
          await _init();
          if (pipeline.status == PipelineStatus.completed) {
            timer.cancel();
          }
        });
      }
    }
  }

  Future<void> _init() async {
    final res = await apiService.getPipeline(projectName: args.project, id: args.id);
    buildDetail.value = res;

    if (buildDetail.value?.isError ?? true) return;

    final realLogs = res.data!.timeline.where((r) => r.order != null && r.order! < 1000);

    final stages = realLogs.where((r) => r.type == 'Stage').sorted((a, b) => a.order!.compareTo(b.order!));
    final phases = realLogs.where((r) => r.type == 'Phase').sorted((a, b) => a.order!.compareTo(b.order!));
    final jobs = realLogs.where((r) => r.type == 'Job').sorted((a, b) => a.order!.compareTo(b.order!));
    final tasks = realLogs.where((r) => r.type == 'Task').sorted((a, b) => a.order!.compareTo(b.order!));

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
                      .map(
                        (j) => _Job(
                          job: j,
                          tasks: tasks.where((t) => t.parentId == j.id).toList(),
                        ),
                      )
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

    final res = await apiService.cancelPipeline(buildId: args.id, projectId: pipeline.project!.id!);

    if (res.isError) {
      return OverlayService.error('Build not canceled', description: 'Try again');
    }

    AppRouter.pop();
  }

  Future<void> _rerunBuild() async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to rerun this pipeline?',
    );
    if (!confirm) return;

    final res = await apiService.rerunPipeline(
      definitionId: pipeline.definition!.id!,
      projectId: pipeline.project!.id!,
      branch: pipeline.sourceBranch!,
    );

    if (res.isError) {
      return OverlayService.error('Build not rerun', description: 'Try again');
    }

    AppRouter.pop();
  }

  String getBuildWebUrl() {
    return '${apiService.basePath}/${pipeline.project!.name}/_build/results?buildId=${args.id}&view=results';
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

    AppRouter.goToPipelineLogs(
      (
        project: pipeline.project!.name!,
        pipelineId: pipeline.id!,
        taskId: t.id,
        parentTaskId: t.parentId!,
        logId: t.log!.id
      ),
    );
  }
}

class _Stage {
  _Stage({
    required this.stage,
    required this.phases,
  });

  final Record stage;
  final List<_Phase> phases;
}

class _Phase {
  _Phase({
    required this.phase,
    required this.jobs,
  });

  final Record phase;
  final List<_Job> jobs;
}

class _Job {
  _Job({
    required this.job,
    required this.tasks,
  });

  final Record job;
  final List<Record> tasks;
}
