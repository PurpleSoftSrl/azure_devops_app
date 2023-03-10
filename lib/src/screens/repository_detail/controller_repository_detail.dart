part of repository_detail;

class _RepositoryDetailController {
  factory _RepositoryDetailController({required AzureApiService apiService, required RepoDetailArgs args}) {
    // handle page already in memory with a different repo
    if (_instances[args.hashCode] != null) {
      return _instances[args.hashCode]!;
    }

    if (instance != null && instance!.args != args) {
      instance = _RepositoryDetailController._(apiService, args, forceRefresh: true);
    }

    instance ??= _RepositoryDetailController._(apiService, args);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _RepositoryDetailController._(this.apiService, this.args, {bool forceRefresh = false}) {
    if (forceRefresh) init();
  }

  static _RepositoryDetailController? instance;

  static final Map<int, _RepositoryDetailController> _instances = {};

  final RepoDetailArgs args;

  final AzureApiService apiService;

  final repoItems = ValueNotifier<ApiResponse<List<RepoItem>>?>(null);

  List<Branch> branches = [];

  Branch? currentBranch;

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    final branchesRes = await apiService.getRepositoryBranches(
      projectName: args.projectName,
      repoName: args.repositoryName,
    );

    branches = branchesRes.data ?? [];

    if (branches.isNotEmpty) {
      currentBranch = branches.firstWhereOrNull((b) => b.isBaseVersion);
    }

    await _getRepoItems();
  }

  Future<void> _getRepoItems() async {
    final itemsRes = await apiService.getRepositoryItems(
      projectName: args.projectName,
      repoName: args.repositoryName,
      path: args.filePath ?? '/',
      branch: currentBranch?.name,
    );

    repoItems.value = itemsRes;
  }

  void goToCommitDetail(Commit commit) {
    AppRouter.goToCommitDetail(commit);
  }

  void goToItem(RepoItem i) {
    final newArgs = args.copyWith(filePath: i.path, branch: currentBranch?.name);
    if (i.isFolder) {
      AppRouter.goToRepositoryDetail(newArgs);
    } else {
      AppRouter.goToFileDetail(newArgs);
    }
  }

  void changeBranch(Branch? b) {
    currentBranch = b;
    _getRepoItems();
  }
}
