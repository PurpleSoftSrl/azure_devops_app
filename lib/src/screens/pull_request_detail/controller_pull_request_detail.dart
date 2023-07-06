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

  final prDetail = ValueNotifier<ApiResponse<PullRequestWithDetails?>?>(null);

  String get prWebUrl =>
      '${apiService.basePath}/${prDetail.value!.data!.pr.repository.project.name}/_git/${prDetail.value!.data!.pr.repository.name}/pullrequest/${prDetail.value!.data!.pr.pullRequestId}';

  final reviewers = <_RevWithDescriptor>[];

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    reviewers.clear();

    final res = await apiService.getPullRequest(
      projectName: args.project,
      repositoryId: args.repository,
      id: args.id,
    );

    res.data?.pr.reviewers.sort((a, b) => a.isRequired ? -1 : 1);

    for (final r in res.data?.pr.reviewers ?? <Reviewer>[]) {
      final descriptor = await _getReviewerDescriptor(r);
      if (descriptor != null) reviewers.add(_RevWithDescriptor(r, descriptor));
    }

    final prAndThreads = _getReplacedPrAndThreads(data: res.data);

    prDetail.value = res.copyWith(data: res.data?.copyWith(pr: prAndThreads.pr, threads: prAndThreads.threads));
  }

  /// Replaces work items links with valid markdown links in description and comments
  ({PullRequest? pr, List<Thread> threads}) _getReplacedPrAndThreads({PullRequestWithDetails? data}) {
    final description = data?.pr.description ?? '';

    PullRequest? pr;

    if (description.isNotEmpty) {
      final replacedDescription = _replaceWorkItemLinks(description);
      pr = data!.pr.copyWith(description: replacedDescription);
    }

    final threads = <Thread>[];

    for (final thread in data?.threads ?? <Thread>[]) {
      final comments = <Comment>[];
      for (final comment in thread.comments) {
        final replacedComment = _replaceWorkItemLinks(comment.content);
        comments.add(comment.copyWith(content: replacedComment));
      }

      threads.add(thread.copyWith(comments: comments));
    }

    return (pr: pr, threads: threads);
  }

  String _replaceWorkItemLinks(String text) {
    return text.splitMapJoin(
      RegExp('#[0-9]+'),
      onMatch: (p0) {
        final item = p0.group(0);
        if (item == null) return p0.input;

        final itemId = item.substring(1);
        return '[$item](workitems/$itemId)';
      },
    );
  }

  void sharePr() {
    shareUrl(prWebUrl);
  }

  void goToRepo() {
    AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: args.project, repositoryName: prDetail.value!.data!.pr.repository.name),
    );
  }

  void goToProject() {
    AppRouter.goToProjectDetail(prDetail.value!.data!.pr.repository.project.name);
  }

  Future<String?> _getReviewerDescriptor(Reviewer r) async {
    final res = await apiService.getUserFromEmail(email: r.uniqueName);
    return res.data?.descriptor ?? '';
  }

  String? _getCommitAuthor(Thread t) {
    final commits = getCommits(t);
    return commits?.toList().firstOrNull?.author?.name;
  }

  int? getCommitIteration(Thread t) {
    final changes = prDetail.value?.data?.changes ?? [];
    if (changes.isEmpty) return null;

    final commitsString = t.properties?.newCommits?.value ?? '';
    if (commitsString.isEmpty) return null;

    final commitIds = t.properties!.newCommits!.value.split(';');

    return changes.firstWhereOrNull((c) => commitIds.contains(c.iteration.sourceRefCommit.commitId))?.iteration.id;
  }

  Iterable<Commit>? getCommits(Thread t) {
    final commits = prDetail.value?.data?.pr.commits ?? [];
    if (commits.isEmpty) return null;

    final commitsString = t.properties?.newCommits?.value ?? '';
    if (commitsString.isEmpty) return null;

    final commitIds = t.properties!.newCommits!.value.toLowerCase().split(';');

    return commits.where((c) => commitIds.contains(c.commitId?.toLowerCase()));
  }

  String? getCommitterDescriptor(Thread t) {
    final commits = getCommits(t);
    final email = commits?.toList().firstOrNull?.author?.email ?? '';
    if (email.isEmpty) return null;

    return apiService.allUsers.firstWhereOrNull((u) => u.mailAddress == email)?.descriptor;
  }

  String? getCommitterDescriptorFromEmail(String? email) {
    if (email == null) return null;
    return apiService.allUsers.firstWhereOrNull((u) => u.mailAddress == email)?.descriptor;
  }

  String getRefUpdateTitle(Thread t) {
    final commitsCount = t.properties?.newCommitsCount?.value ?? 1;
    final commits = commitsCount > 1 ? 'commits' : 'commit';
    return '${_getCommitAuthor(t) ?? '-'} pushed $commitsCount $commits';
  }

  void goToCommitDetail(String commitId) {
    AppRouter.goToCommitDetail(project: args.project, repository: args.repository, commitId: commitId);
  }

  Future<void> onTapMarkdownLink(String text, String? href, String? _) async {
    final isWorkItemLink = text.startsWith(RegExp('#[0-9]+'));
    if (isWorkItemLink) {
      final id = href!.split('/').last;
      final parsedId = int.tryParse(id);
      if (parsedId == null) return;

      unawaited(AppRouter.goToWorkItemDetail(project: args.project, id: parsedId));
      return;
    }

    if (await canLaunchUrlString(href!)) await launchUrlString(href);
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
