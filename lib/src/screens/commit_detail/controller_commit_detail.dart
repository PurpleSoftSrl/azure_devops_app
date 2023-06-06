part of commit_detail;

class _CommitDetailController with ShareMixin {
  factory _CommitDetailController({required CommitDetailArgs args, required AzureApiService apiService}) {
    // handle page already in memory with a different commit
    if (_instances[args.hashCode] != null) {
      return _instances[args.hashCode]!;
    }

    if (instance != null && args.commitId != instance!.args.commitId) {
      instance = _CommitDetailController._(args, apiService);
    }

    instance ??= _CommitDetailController._(args, apiService);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _CommitDetailController._(this.args, this.apiService);

  static _CommitDetailController? instance;

  static final Map<int, _CommitDetailController> _instances = {};

  final CommitDetailArgs args;
  final AzureApiService apiService;

  final commitChanges = ValueNotifier<ApiResponse<CommitWithChanges?>?>(null);

  Commit? commitDetail;

  Iterable<Change?> get changedFiles =>
      commitChanges.value?.data?.changes?.changes?.where((c) => c!.item!.gitObjectType == 'blob') ?? [];

  Iterable<Change?> get addedFiles => changedFiles.where((f) => f!.changeType == 'add');
  int get addedFilesCount => addedFiles.length;

  Iterable<Change?> get editedFiles => changedFiles.where((f) => f!.changeType == 'edit');
  int get editedFilesCount => editedFiles.length;

  Iterable<Change?> get deletedFiles => changedFiles.where((f) => f!.changeType == 'delete');
  int get deletedFilesCount => deletedFiles.length;

  int get addedLines => commitChanges.value?.data?.changes?.changeCounts?.add ?? 0;
  int get editedLines => commitChanges.value?.data?.changes?.changeCounts?.edit ?? 0;
  int get deletedLines => commitChanges.value?.data?.changes?.changeCounts?.delete ?? 0;

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    final detailRes = await apiService.getCommitDetail(
      projectId: args.project,
      repositoryId: args.repository,
      commitId: args.commitId,
    );

    commitDetail = detailRes.data?.commit;
    commitChanges.value = detailRes;
  }

  void shareDiff() {
    shareUrl(diffUrl);
  }

  String get diffUrl =>
      '${apiService.basePath}/${commitDetail!.projectName}/_git/${commitDetail!.repositoryName}/commit/${commitDetail!.commitId}';

  void goToProject() {
    AppRouter.goToProjectDetail(commitDetail!.projectName);
  }

  Future<void> goToRepo() async {
    await AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: commitDetail!.projectName, repositoryName: commitDetail!.repositoryName),
    );
  }

  void goToFileDiff({required String filePath, bool isAdded = false, bool isDeleted = false}) {
    AppRouter.goToFileDiff(
      FileDiffArgs(
        commit: commitDetail!,
        filePath: filePath,
        isAdded: isAdded,
        isDeleted: isDeleted,
      ),
    );
  }
}
