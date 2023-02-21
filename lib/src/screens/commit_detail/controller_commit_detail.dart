part of commit_detail;

class _CommitDetailController {
  factory _CommitDetailController({required Commit commit, required AzureApiService apiService}) {
    // handle page already in memory with a different commit
    if (_instances[commit.hashCode] != null) {
      return _instances[commit.hashCode]!;
    }

    if (instance != null && commit.commitId != instance!.commit.commitId) {
      instance = _CommitDetailController._(commit, apiService, forceRefresh: true);
    }

    instance ??= _CommitDetailController._(commit, apiService);
    return _instances.putIfAbsent(commit.hashCode, () => instance!);
  }

  _CommitDetailController._(this.commit, this.apiService, {bool forceRefresh = false}) {
    if (forceRefresh) init();
  }

  static _CommitDetailController? instance;

  static final Map<int, _CommitDetailController> _instances = {};

  final Commit commit;
  final AzureApiService apiService;

  final commitDetail = ValueNotifier<ApiResponse<CommitDetail?>?>(null);

  GraphUser? author;

  Iterable<Change?> get changedFiles =>
      commitDetail.value?.data!.changes!.where((c) => c!.item!.gitObjectType == 'blob') ?? [];

  Iterable<Change?> get addedFiles => changedFiles.where((f) => f!.changeType == 'add');
  int get addedFilesCount => addedFiles.length;

  Iterable<Change?> get editedFiles => changedFiles.where((f) => f!.changeType == 'edit');
  int get editedFilesCount => editedFiles.length;

  Iterable<Change?> get deletedFiles => changedFiles.where((f) => f!.changeType == 'delete');
  int get deletedFilesCount => deletedFiles.length;

  void dispose() {
    instance = null;
    _instances.remove(commit.hashCode);
  }

  Future<void> init() async {
    final detailRes = await apiService.getCommitDetail(
      projectId: commit.projectName,
      repositoryId: commit.repositoryName,
      commitId: commit.commitId!,
    );

    final authorRes = await apiService.getUserFromEmail(email: commit.author!.email!);
    author = authorRes.data;

    commitDetail.value = detailRes;
  }

  void shareDiff() {
    Share.share(diffUrl);
  }

  String get diffUrl =>
      '${apiService.basePath}/${commit.projectName}/_git/${commit.repositoryName}/commit/${commit.commitId}';

  void goToProject() {
    AppRouter.goToProjectDetail(commit.projectName);
  }

  Future<void> goToRepo() async {
    await AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: commit.projectName, repositoryName: commit.repositoryName),
    );
  }

  void goToFileDiff({required String filePath, required bool isAdded}) {
    AppRouter.goToFileDiff(
      FileDiffArgs(
        commit: commit,
        filePath: filePath,
        isAdded: isAdded,
      ),
    );
  }
}
