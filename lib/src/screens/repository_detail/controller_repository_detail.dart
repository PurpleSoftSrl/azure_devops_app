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

  final commits = ValueNotifier<ApiResponse<List<Commit>?>?>(null);

  final now = DateTime.now();
  static const _top = 10;
  var _skip = 0;

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    _skip = 0;

    final commitsRes = await _getData();
    commits.value = commitsRes;
  }

  Future<bool> loadMore() async {
    _skip += _top;

    final nextDayData = await _getData();

    if ((nextDayData.data?.length ?? 0) <= 0) {
      return false;
    }

    nextDayData.data?.sort((a, b) => b.author!.date!.compareTo(a.author!.date!));

    commits.value = nextDayData..data!.insertAll(0, commits.value!.data!);

    return true;
  }

  Future<ApiResponse<List<Commit>>> _getData() async {
    final res = await apiService.getRepositoryCommits(
      projectName: args.projectName,
      repoName: args.repositoryName,
      top: _top,
      skip: _skip,
    );

    return res..data?.sorted((a, b) => b.author!.date!.compareTo(a.author!.date!));
  }

  void goToCommitDetail(Commit commit) {
    AppRouter.goToCommitDetail(commit);
  }
}
