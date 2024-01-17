part of commit_detail;

class _CommitDetailController with ShareMixin {
  _CommitDetailController._(this.args, this.apiService);

  final CommitDetailArgs args;
  final AzureApiService apiService;

  final commitChanges = ValueNotifier<ApiResponse<CommitWithChanges?>?>(null);

  Commit? get commit => commitChanges.value?.data?.commit;

  Iterable<Change?> get changedFiles =>
      commitChanges.value?.data?.changes?.changes?.where((c) => c!.item!.gitObjectType == 'blob') ?? [];

  Iterable<Change?> get addedFiles => changedFiles.where((f) => f!.changeType == 'add');
  int get addedFilesCount => addedFiles.length;

  Iterable<Change?> get editedFiles => changedFiles.where((f) => f!.changeType == 'edit');
  int get editedFilesCount => editedFiles.length;

  Iterable<Change?> get deletedFiles => changedFiles.where((f) => f!.changeType == 'delete');
  int get deletedFilesCount => deletedFiles.length;

  final groupedEditedFiles = <String, Set<ChangedFileDiff>>{};
  final groupedAddedFiles = <String, Set<ChangedFileDiff>>{};
  final groupedDeletedFiles = <String, Set<ChangedFileDiff>>{};

  Future<void> init() async {
    final detailRes = await apiService.getCommitDetail(
      projectId: args.project,
      repositoryId: args.repository,
      commitId: args.commitId,
    );

    final changes = detailRes.data?.changes?.changes ?? <Change>[];
    _getChangedFiles(changes);

    commitChanges.value = detailRes;
  }

  void _getChangedFiles(List<Change?> changes) {
    for (final file in changes.where((f) => f?.item?.gitObjectType == 'blob' && f?.item?.path != null)) {
      final path = file!.item!.path;
      if (path == null) continue;

      final directory = dirname(path);
      final fileName = basename(path);

      final diff = ChangedFileDiff(
        commitId: file.item!.commitId!,
        parentCommitId: '',
        directory: directory,
        fileName: fileName,
        path: path,
        changeType: switch (file.changeType) { 'add' => 'added', 'edit' => 'edited', 'delete' => 'deleted', _ => '' },
      );
      if (file.changeType == 'add') {
        groupedAddedFiles.putIfAbsent(directory, () => {diff});
        groupedAddedFiles[directory]!.add(diff);
      } else if (file.changeType == 'edit') {
        groupedEditedFiles.putIfAbsent(directory, () => {diff});
        groupedEditedFiles[directory]!.add(diff);
      } else if (file.changeType == 'delete') {
        groupedDeletedFiles.putIfAbsent(directory, () => {diff});
        groupedDeletedFiles[directory]!.add(diff);
      }
    }
  }

  void shareDiff() {
    shareUrl(diffUrl);
  }

  String get diffUrl =>
      '${apiService.basePath}/${commit!.projectName}/_git/${commit!.repositoryName}/commit/${commit!.commitId}';

  void goToProject() {
    AppRouter.goToProjectDetail(commit!.projectName);
  }

  Future<void> goToRepo() async {
    await AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: commit!.projectName, repositoryName: commit!.repositoryName),
    );
  }

  void goToFileDiff({required ChangedFileDiff diff, bool isAdded = false, bool isDeleted = false}) {
    AppRouter.goToFileDiff(
      (
        commit: commit!,
        filePath: diff.path,
        isAdded: isAdded,
        isDeleted: isDeleted,
        pullRequestId: null,
      ),
    );
  }
}
