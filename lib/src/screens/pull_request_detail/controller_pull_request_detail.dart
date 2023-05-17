part of pull_request_detail;

class _PullRequestDetailController with ShareMixin {
  factory _PullRequestDetailController({required PullRequest pullRequest, required AzureApiService apiService}) {
    // handle page already in memory with a different work item
    if (_instances[pullRequest.hashCode] != null) {
      return _instances[pullRequest.hashCode]!;
    }

    if (instance != null && instance!.pullRequest != pullRequest) {
      instance = _PullRequestDetailController._(pullRequest, apiService);
    }

    instance ??= _PullRequestDetailController._(pullRequest, apiService);
    return _instances.putIfAbsent(pullRequest.hashCode, () => instance!);
  }

  _PullRequestDetailController._(this.pullRequest, this.apiService);

  static _PullRequestDetailController? instance;

  static final Map<int, _PullRequestDetailController> _instances = {};

  final PullRequest pullRequest;

  final AzureApiService apiService;

  final prDetail = ValueNotifier<ApiResponse<PullRequest?>?>(null);

  String get prWebUrl =>
      '${apiService.basePath}/${pullRequest.repository.project.name}/_git/${pullRequest.repository.name}/pullrequest/${pullRequest.pullRequestId}';

  final reviewers = <_RevWithDescriptor>[];

  void dispose() {
    instance = null;
    _instances.remove(pullRequest.hashCode);
  }

  Future<void> init() async {
    reviewers.clear();

    final res = await apiService.getPullRequest(
      projectName: pullRequest.repository.project.name,
      id: pullRequest.pullRequestId,
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
      RepoDetailArgs(projectName: pullRequest.repository.project.name, repositoryName: pullRequest.repository.name),
    );
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
