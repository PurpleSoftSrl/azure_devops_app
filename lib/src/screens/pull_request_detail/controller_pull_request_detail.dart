part of pull_request_detail;

class _PullRequestDetailController with ShareMixin {
  factory _PullRequestDetailController({
    required PullRequestDetailArgs args,
    required AzureApiService apiService,
  }) {
    // handle page already in memory with a different work item
    if (_instances[args.hashCode] != null) {
      return _instances[args.hashCode]!;
    }

    if (instance != null && instance!.args != args) {
      instance = _PullRequestDetailController._(args, apiService);
    }

    instance ??= _PullRequestDetailController._(args, apiService);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _PullRequestDetailController._(this.args, this.apiService);

  static _PullRequestDetailController? instance;

  static final Map<int, _PullRequestDetailController> _instances = {};

  final PullRequestDetailArgs args;

  final AzureApiService apiService;

  final prDetail = ValueNotifier<ApiResponse<PullRequest?>?>(null);

  String get prWebUrl =>
      '${apiService.basePath}/${prDetail.value!.data!.repository.project.name}/_git/${prDetail.value!.data!.repository.name}/pullrequest/${prDetail.value!.data!.pullRequestId}';

  final reviewers = <_RevWithDescriptor>[];

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    reviewers.clear();

    final res = await apiService.getPullRequest(
      projectName: args.project,
      id: args.id,
    );

    res.data?.reviewers.sort((a, b) => a.isRequired ? -1 : 1);

    for (final r in res.data?.reviewers ?? <Reviewer>[]) {
      final descriptor = await _getReviewerDescriptor(r);
      reviewers.add(_RevWithDescriptor(r, descriptor));
    }

    prDetail.value = res;
  }

  void sharePr() {
    shareUrl(prWebUrl);
  }

  void goToRepo() {
    AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: args.project, repositoryName: prDetail.value!.data!.repository.name),
    );
  }

  void goToProject() {
    AppRouter.goToProjectDetail(prDetail.value!.data!.repository.project.name);
  }

  Future<String> _getReviewerDescriptor(Reviewer r) async {
    final res = await apiService.getUserFromEmail(email: r.uniqueName);
    return res.data?.descriptor ?? '';
  }
}

class _RevWithDescriptor {
  _RevWithDescriptor(
    this.reviewer,
    this.descriptor,
  );

  final Reviewer reviewer;
  final String descriptor;

  @override
  String toString() => 'RevWithDescriptor(reviewer: $reviewer, descriptor: $descriptor)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _RevWithDescriptor && other.reviewer == reviewer && other.descriptor == descriptor;
  }

  @override
  int get hashCode => reviewer.hashCode ^ descriptor.hashCode;
}
