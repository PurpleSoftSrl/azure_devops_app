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

  List<_RevWithDescriptor> reviewers = <_RevWithDescriptor>[];

  final groupedEditedFiles = <String, Set<ChangedFileDiff>>{};
  final groupedAddedFiles = <String, Set<ChangedFileDiff>>{};
  final groupedDeletedFiles = <String, Set<ChangedFileDiff>>{};

  Iterable<ChangeEntry?> get changedFiles => prDetail.value?.data?.changes.expand((c) => c.changes) ?? [];

  Iterable<ChangeEntry?> get addedFiles => changedFiles.where((f) => f!.changeType == 'add');
  int get addedFilesCount => addedFiles.length;

  Iterable<ChangeEntry?> get editedFiles => changedFiles.where((f) => f!.changeType == 'edit');
  int get editedFilesCount => editedFiles.length;

  Iterable<ChangeEntry?> get deletedFiles => changedFiles.where((f) => f!.changeType == 'delete');
  int get deletedFilesCount => deletedFiles.length;

  final visiblePage = ValueNotifier<int>(0);

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    final res = await apiService.getPullRequest(
      projectName: args.project,
      repositoryId: args.repository,
      id: args.id,
    );

    res.data?.pr.reviewers.sort((a, b) => a.isRequired ? -1 : 1);

    final revs = <_RevWithDescriptor>[];
    for (final r in res.data?.pr.reviewers ?? <Reviewer>[]) {
      final descriptor = await _getReviewerDescriptor(r);
      if (descriptor != null) revs.add(_RevWithDescriptor(r, descriptor));
    }

    reviewers = [...revs];

    _getChangedFiles(res);

    final prAndThreads = _getReplacedPrAndThreads(data: res.data);

    prDetail.value = res.copyWith(data: res.data?.copyWith(pr: prAndThreads.pr, updates: prAndThreads.updates));
  }

  void _getChangedFiles(ApiResponse<PullRequestWithDetails> res) {
    final commitsWithChanges = res.data?.changes ?? <CommitWithChangeEntry>[];

    for (final commitWithChange in commitsWithChanges) {
      for (final file in commitWithChange.changes) {
        final path = file.item.path ?? file.originalPath;
        if (path == null) continue;

        final directory = dirname(path);
        final fileName = basename(path);

        final newestCommitId = commitsWithChanges
            .where((commit) => commit.changes.any((c) => c.item.path == path || c.originalPath == path))
            .reduce((a, b) => a.iteration.id >= b.iteration.id ? a : b)
            .iteration
            .sourceRefCommit
            .commitId;

        final oldestCommitId = commitsWithChanges
            .where((commit) => commit.changes.any((c) => c.item.path == path || c.originalPath == path))
            .reduce((a, b) => a.iteration.id <= b.iteration.id ? a : b)
            .iteration
            .commonRefCommit
            .commitId;

        final diff = ChangedFileDiff(
          commitId: newestCommitId,
          parentCommitId: oldestCommitId,
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
  }

  /// Replaces work items links with valid markdown links in description and comments
  ({PullRequest? pr, List<PullRequestUpdate> updates}) _getReplacedPrAndThreads({PullRequestWithDetails? data}) {
    final description = data?.pr.description ?? '';

    PullRequest? pr;

    if (description.isNotEmpty) {
      final replacedDescription = _replaceWorkItemLinks(description);
      pr = data!.pr.copyWith(description: replacedDescription);
    }

    final updates = <PullRequestUpdate>[];

    for (final update in data?.updates ?? <PullRequestUpdate>[]) {
      if (update is CommentUpdate) {
        final replacedComment = _replaceWorkItemLinks(update.content);
        updates.add(update.copyWith(content: replacedComment));
      } else {
        updates.add(update);
      }
    }

    return (pr: pr, updates: updates);
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

  // ignore: use_setters_to_change_properties
  void selectPage(int i, TabController tabController) {
    visiblePage.value = i;
    tabController
      ..animateTo(i)
      ..index = i;
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

  Future<void> goToFileDiff({required ChangedFileDiff diff, bool isAdded = false, bool isDeleted = false}) async {
    final commit = c.Commit(
      commitId: diff.commitId,
      parents: [diff.parentCommitId],
      url: '${apiService.basePath}/${args.project}/_apis/git/repositories/${args.repository}/commits/${diff.commitId}',
    );

    await AppRouter.goToFileDiff(
      (commit: commit, filePath: diff.path, isAdded: isAdded, isDeleted: isDeleted),
    );
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
