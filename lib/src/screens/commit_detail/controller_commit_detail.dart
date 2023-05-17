part of commit_detail;

class _CommitDetailController with ShareMixin {
  factory _CommitDetailController({required Commit commit, required AzureApiService apiService}) {
    // handle page already in memory with a different commit
    if (_instances[commit.hashCode] != null) {
      return _instances[commit.hashCode]!;
    }

    if (instance != null && commit.commitId != instance!.commit.commitId) {
      instance = _CommitDetailController._(commit, apiService);
    }

    instance ??= _CommitDetailController._(commit, apiService);
    return _instances.putIfAbsent(commit.hashCode, () => instance!);
  }

  _CommitDetailController._(this.commit, this.apiService);

  static _CommitDetailController? instance;

  static final Map<int, _CommitDetailController> _instances = {};

  final Commit commit;
  final AzureApiService apiService;

  final commitChanges = ValueNotifier<ApiResponse<CommitChanges?>?>(null);

  Commit? commitDetail;

  GraphUser? author;

  Iterable<Change?> get changedFiles =>
      commitChanges.value?.data!.changes!.where((c) => c!.item!.gitObjectType == 'blob') ?? [];

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
    final changesRes = await apiService.getCommitChanges(
      projectId: commit.projectName,
      repositoryId: commit.repositoryName,
      commitId: commit.commitId!,
    );

    final detailRes = await apiService.getCommitDetail(
      projectId: commit.projectName,
      repositoryId: commit.repositoryName,
      commitId: commit.commitId!,
    );

    commitDetail = detailRes.data;

    if (commitDetail != null) {
      final authorRes = await apiService.getUserFromEmail(email: commitDetail!.author!.email!);
      author = authorRes.data;
    }

    commitChanges.value = changesRes;
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
