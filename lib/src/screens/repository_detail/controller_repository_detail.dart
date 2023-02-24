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

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    final itemsRes = await apiService.getRepositoryItems(
      projectName: args.projectName,
      repoName: args.repositoryName,
      path: args.filePath ?? '/',
    );

    repoItems.value = itemsRes;
  }

  void goToCommitDetail(Commit commit) {
    AppRouter.goToCommitDetail(commit);
  }

  void goToItem(RepoItem i) {
    if (i.isFolder) {
      final newArgs = args.copyWith(isFolder: true, filePath: i.path);
      AppRouter.goToRepositoryDetail(newArgs);
    } else {
      final newArgs = args.copyWith(filePath: i.path);
      AppRouter.goToFileDetail(newArgs);
    }
  }
}
