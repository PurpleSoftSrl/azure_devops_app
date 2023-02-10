part of pipeline_detail;

class _PipelineDetailController {
  factory _PipelineDetailController({required Pipeline pipeline, required AzureApiService apiService}) {
    // handle page already in memory with a different build
    if (_instances[pipeline.hashCode] != null) {
      return _instances[pipeline.hashCode]!;
    }

    if (instance != null && pipeline.id != instance!.pipeline.id) {
      instance = _PipelineDetailController._(pipeline, apiService, forceRefresh: true);
    }

    instance ??= _PipelineDetailController._(pipeline, apiService);
    return _instances.putIfAbsent(pipeline.hashCode, () => instance!);
  }

  _PipelineDetailController._(this.pipeline, this.apiService, {bool forceRefresh = false}) {
    if (forceRefresh) init();
  }

  static _PipelineDetailController? instance;

  static final Map<int, _PipelineDetailController> _instances = {};

  final Pipeline pipeline;
  final AzureApiService apiService;

  final buildDetail = ValueNotifier<ApiResponse<Pipeline?>?>(null);

  void dispose() {
    instance = null;
    _instances.remove(pipeline.hashCode);
  }

  Future<void> init() async {
    final res = await apiService.getPipeline(projectName: pipeline.project!.name!, id: pipeline.id!);
    buildDetail.value = res;
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

  Future<void> _cancelBuild() async {
    final confirm = await AlertService.confirm(
      'Do you really want to cancel this pipeline?',
    );
    if (!confirm) return;

    final res = await apiService.cancelPipeline(buildId: pipeline.id!, projectId: pipeline.project!.id!);

    if (res.isError) {
      return AlertService.error('Build not canceled', description: 'Try again');
    }

    AppRouter.pop();
  }

  Future<void> _rerunBuild() async {
    final confirm = await AlertService.confirm(
      'Do you really want to rerun this pipeline?',
    );
    if (!confirm) return;

    final res = await apiService.rerunPipeline(
      definitionId: pipeline.definition!.id!,
      projectId: pipeline.project!.id!,
      branch: pipeline.sourceBranch!,
    );

    if (res.isError) {
      return AlertService.error('Build not rerun', description: 'Try again');
    }

    AppRouter.pop();
  }

  String getBuildWebUrl() {
    return '${apiService.basePath}/${pipeline.project!.name}/_build/results?buildId=${pipeline.id}&view=results';
  }

  void shareBuild() {
    Share.share(getBuildWebUrl());
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
    await AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: pipeline.project!.name!, repositoryName: pipeline.repository!.name!),
    );
  }

  void goToCommitDetail() {
    final commit = Commit(
      commitId: pipeline.triggerInfo!.ciSourceSha,
      author: Author(
        date: pipeline.queueTime,
        email: pipeline.requestedFor!.uniqueName,
        name: pipeline.requestedFor!.displayName,
      ),
      committer: null,
      comment: pipeline.triggerInfo!.ciMessage,
      changeCounts: null,
      url: null,
      remoteUrl:
          '${apiService.basePath}/${pipeline.project!.name}/_git/${pipeline.repository!.name}/commit/${pipeline.triggerInfo!.ciSourceSha}',
    );

    AppRouter.goToCommitDetail(commit);
  }
}
