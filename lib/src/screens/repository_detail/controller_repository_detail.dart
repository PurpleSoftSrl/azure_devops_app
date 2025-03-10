part of repository_detail;

class _RepositoryDetailController {
  _RepositoryDetailController._(this.api, this.args);

  final RepoDetailArgs args;
  final AzureApiService api;

  final repoItems = ValueNotifier<ApiResponse<List<RepoItem>?>?>(null);

  List<Branch> branches = [];

  Branch? currentBranch;

  Future<void> init() async {
    final branchesRes = await api.getRepositoryBranches(
      projectName: args.projectName,
      repoName: args.repositoryName,
    );

    branches = branchesRes.data ?? [];

    if (branches.isNotEmpty) {
      currentBranch = args.branch != null
          ? branches.firstWhereOrNull((b) => b.name == args.branch)
          : branches.firstWhereOrNull((b) => b.isBaseVersion);
      branches = [currentBranch!, ...branches.where((b) => b != currentBranch)];
    }

    await _getRepoItems();
  }

  Future<void> _getRepoItems() async {
    final itemsRes = await api.getRepositoryItems(
      projectName: args.projectName,
      repoName: args.repositoryName,
      path: args.filePath ?? '/',
      branch: currentBranch?.name,
    );

    repoItems.value = itemsRes;
  }

  void goToCommitDetail(Commit commit) {
    AppRouter.goToCommitDetail(
      project: commit.projectName,
      repository: commit.repositoryName,
      commitId: commit.commitId!,
    );
  }

  void goToItem(RepoItem item) {
    final newArgs = args.copyWith(filePath: item.path, branch: currentBranch?.name);
    if (item.isFolder) {
      AppRouter.goToRepositoryDetail(newArgs);
    } else {
      AppRouter.goToFileDetail(newArgs);
    }
  }

  void changeBranch(Branch? branch) {
    currentBranch = branch;
    _getRepoItems();
  }
}
