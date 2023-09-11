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

  final groupedConflictingFiles = <String, Set<ChangedFileDiff>>{};

  bool get mustSatisfyPolicies =>
      prDetail.value?.data?.policies.where((p) => p.status != 'approved').isNotEmpty ?? false;

  bool get mustBeApproved => reviewers.where((p) => p.reviewer.isRequired && p.reviewer.vote < 5).isNotEmpty;

  bool get hasAutoCompleteOn => prDetail.value?.data?.pr.autoCompleteSetBy != null;

  bool canBeReactivated = true;

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

    final pr = res.data?.pr;
    pr?.reviewers.sort((a, b) => a.isRequired ? -1 : 1);

    final revs = <_RevWithDescriptor>[];
    for (final r in pr?.reviewers ?? <Reviewer>[]) {
      final descriptor = await _getReviewerDescriptor(r);
      if (descriptor != null) revs.add(_RevWithDescriptor(r, descriptor));
    }

    reviewers = [...revs];

    final changes = res.data?.changes ?? <CommitWithChangeEntry>[];
    if (changes.isNotEmpty) _getChangedFiles(changes);

    final conflicts = res.data?.conflicts ?? <Conflict>[];
    if (conflicts.isNotEmpty) _getConflictingFiles(conflicts);

    final prAndThreads = _getReplacedPrAndThreads(data: res.data);

    if (pr?.status == PullRequestState.abandoned) {
      canBeReactivated = await _checkIfCanBeReactivated(pr!);
    }

    prDetail.value = res.copyWith(data: res.data?.copyWith(pr: prAndThreads.pr, updates: prAndThreads.updates));
  }

  void _getChangedFiles(List<CommitWithChangeEntry> changes) {
    for (final change in changes) {
      for (final file in change.changes) {
        final path = file.item.path ?? file.originalPath;
        if (path == null) continue;

        final directory = dirname(path);
        final fileName = basename(path);

        final newestCommitId = changes
            .where((commit) => commit.changes.any((c) => c.item.path == path || c.originalPath == path))
            .reduce((a, b) => a.iteration.id >= b.iteration.id ? a : b)
            .iteration
            .sourceRefCommit
            .commitId;

        final oldestCommitId = changes
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

  void _getConflictingFiles(List<Conflict> conflicts) {
    for (final conflict in conflicts) {
      final directory = dirname(conflict.conflictPath);
      final fileName = basename(conflict.conflictPath);

      final diff = ChangedFileDiff(
        commitId: '',
        parentCommitId: '',
        path: conflict.conflictPath,
        directory: directory,
        fileName: fileName,
        changeType: 'conflicting',
      );

      groupedConflictingFiles.putIfAbsent(directory, () => {diff});
      groupedConflictingFiles[directory]!.add(diff);
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

  /// An abandoned PR can be reactivated only if sourceBranch has not been deleted
  Future<bool> _checkIfCanBeReactivated(PullRequest pr) async {
    final sourceBranch = pr.sourceBranch;
    final res = await apiService.getRepositoryBranches(
      projectName: pr.repository.project.id,
      repoName: pr.repository.name,
    );
    if (res.isError) return false;

    final branches = res.data ?? [];
    for (final branch in branches) {
      if (branch.name == sourceBranch) {
        return true;
      }
    }

    return false;
  }

  // ignore: use_setters_to_change_properties
  void selectPage(int i, TabController tabController) {
    visiblePage.value = i;
    tabController
      ..animateTo(i)
      ..index = i;
  }

  void sharePr() {
    final pr = prDetail.value!.data!.pr;
    final project = pr.repository.project.name;
    final repository = pr.repository.name;
    final id = pr.pullRequestId;
    final prWebUrl = '${apiService.basePath}/$project/_git/$repository/pullrequest/$id';

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
    final projectName = prDetail.value!.data!.pr.repository.project.name;
    final repositoryName = prDetail.value!.data!.pr.repository.name;
    AppRouter.goToCommitDetail(project: projectName, repository: repositoryName, commitId: commitId);
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
      remoteUrl: '${apiService.basePath}/${args.project}/_git/${args.repository}/commit/${diff.commitId}',
      url: '${apiService.basePath}/${args.project}/_apis/git/repositories/${args.repository}/commits/${diff.commitId}',
    );

    await AppRouter.goToFileDiff(
      (commit: commit, filePath: diff.path, isAdded: isAdded, isDeleted: isDeleted),
    );
  }

  Future<void> approve() async {
    return _votePr(vote: 10);
  }

  Future<void> approveWithSugestions() async {
    return _votePr(vote: 5);
  }

  Future<void> waitForAuthor() async {
    return _votePr(vote: -5);
  }

  Future<void> reject() async {
    return _votePr(vote: -10);
  }

  Future<void> markAsDraft() async {
    return _editPr(isDraft: true);
  }

  Future<void> publish() async {
    return _editPr(isDraft: false);
  }

  Future<void> setAutocomplete({required bool autocomplete}) async {
    return _editPr(autocomplete: autocomplete);
  }

  Future<void> complete() async {
    return _editPr(status: PullRequestState.completed);
  }

  Future<void> abandon() async {
    return _editPr(status: PullRequestState.abandoned);
  }

  Future<void> reactivate() async {
    return _editPr(status: PullRequestState.active);
  }

  Future<void> _votePr({required int vote}) async {
    final user = apiService.user!;
    final reviewer = prDetail.value!.data!.pr.reviewers.firstWhereOrNull((r) => r.uniqueName == user.emailAddress) ??
        Reviewer(
          vote: vote,
          hasDeclined: false,
          isFlagged: false,
          isRequired: false,
          displayName: user.displayName!,
          id: '',
          uniqueName: user.emailAddress!,
        );

    final res = await apiService.votePullRequest(
      projectName: args.project,
      repositoryId: args.repository,
      id: args.id,
      reviewer: reviewer.copyWith(vote: vote),
    );

    if (res.isError) {
      await OverlayService.error('Error', description: 'Pull request not edited');
      return;
    }

    await init();
  }

  Future<void> _editPr({PullRequestState? status, bool? isDraft, bool? autocomplete}) async {
    var confirmMessage = '';
    if (status != null) {
      confirmMessage = '${status.toVerb()} the pull request';
    } else if (isDraft != null) {
      confirmMessage = isDraft ? 'mark the pull request as draft' : 'publish the pull request';
    } else if (autocomplete != null) {
      confirmMessage = autocomplete ? 'set auto-complete' : 'cancel auto-complete';
    }

    final conf = await OverlayService.confirm('Attention', description: 'Do you really want to $confirmMessage?');
    if (!conf) return;

    PullRequestCompletionOptions? completionOptions;

    if (status == PullRequestState.completed || (autocomplete ?? false)) {
      completionOptions = await _getCompletionOptions();
      if (completionOptions == null) return;
    }

    final res = await apiService.editPullRequest(
      projectName: args.project,
      repositoryId: args.repository,
      id: args.id,
      status: status,
      isDraft: isDraft ?? prDetail.value!.data!.pr.isDraft,
      commitId: prDetail.value!.data!.changes.first.iteration.sourceRefCommit.commitId,
      autocomplete: autocomplete,
      completionOptions: completionOptions,
    );

    if (res.isError) {
      await OverlayService.error('Error', description: 'Pull request not edited');
      return;
    }

    await init();
  }

  // ignore: long-method
  Future<PullRequestCompletionOptions?> _getCompletionOptions() async {
    const mergeTypes = {
      1: 'Merge (no fast forward)',
      2: 'Squash commit',
      3: 'Rebase and fast-forward',
      4: 'Semi-linear merge',
    };

    var mergeType = 1;
    var completeWorkItems = false;
    var deleteSourceBranch = false;
    var customizeCommitMessage = false;
    String? commitMessage;

    final branchesRes = await apiService.getRepositoryBranches(projectName: args.project, repoName: args.repository);
    final branch = (branchesRes.data ?? []).firstWhereOrNull((b) => b.name == prDetail.value!.data!.pr.sourceBranch);
    final canDeleteBranch = !(branch?.isBaseVersion ?? false);

    final mergeTypeFieldController = TextEditingController(text: mergeTypes.entries.first.value);

    var hasConfirmed = false;

    await OverlayService.bottomsheet(
      isScrollControlled: true,
      title: 'Completion options',
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DevOpsFormField(
                  onChanged: (_) => true,
                  enabled: false,
                  controller: mergeTypeFieldController,
                ),
              ),
              const SizedBox(width: 20),
              DevOpsPopupMenu(
                tooltip: 'Merge type',
                items: () => mergeTypes.entries
                    .map(
                      (entry) => PopupItem(
                        text: entry.value,
                        onTap: () {
                          mergeTypeFieldController.text = entry.value;
                          mergeType = entry.key;
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'Post-completion options',
            style: context.textTheme.labelMedium,
          ),
          const SizedBox(height: 10),
          StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(
                    'Complete associated work items after merging',
                    style: context.textTheme.bodySmall,
                  ),
                  value: completeWorkItems,
                  onChanged: (_) => setState(() => completeWorkItems = !completeWorkItems),
                  contentPadding: EdgeInsets.zero,
                ),
                if (canDeleteBranch)
                  CheckboxListTile(
                    title: Text(
                      'Delete ${prDetail.value!.data!.pr.sourceBranch} after merging',
                      style: context.textTheme.bodySmall,
                    ),
                    value: deleteSourceBranch,
                    onChanged: (_) => setState(() => deleteSourceBranch = !deleteSourceBranch),
                    contentPadding: EdgeInsets.zero,
                  ),
                CheckboxListTile(
                  title: Text(
                    'Customize merge commit message',
                    style: context.textTheme.bodySmall,
                  ),
                  value: customizeCommitMessage,
                  onChanged: (_) => setState(() => customizeCommitMessage = !customizeCommitMessage),
                  contentPadding: EdgeInsets.zero,
                ),
                if (customizeCommitMessage)
                  DevOpsFormField(
                    initialValue:
                        'Merged PR ${prDetail.value!.data!.pr.pullRequestId}: ${prDetail.value!.data!.pr.title}',
                    onChanged: (s) => commitMessage = s,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 150),
          LoadingButton(
            onPressed: () {
              hasConfirmed = true;
              AppRouter.popRoute();
            },
            text: 'Confirm',
          ),
        ],
      ),
    );

    if (!hasConfirmed) return null;

    return (
      mergeType: mergeType,
      completeWorkItems: completeWorkItems,
      deleteSourceBranch: deleteSourceBranch,
      commitMessage: commitMessage
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
