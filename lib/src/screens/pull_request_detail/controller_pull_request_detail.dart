part of pull_request_detail;

class _PullRequestDetailController with ShareMixin, AppLogger, PullRequestHelper {
  _PullRequestDetailController._(this.args, this.apiService, this.ads);

  final PullRequestDetailArgs args;

  final AzureApiService apiService;
  final AdsService ads;

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

  static const _requireMergeStrategyId = 'fa4e907d-c16b-4a4c-9dfa-4916e5d171ab';

  bool get mustSatisfyPolicies =>
      prDetail.value?.data?.policies
          // filter out the merge strategy policy to allow completing the PR
          .where((p) => p.configuration?.type?.id != _requireMergeStrategyId && p.status != 'approved')
          .isNotEmpty ??
      false;

  bool get mustBeApproved => reviewers.where((p) => p.reviewer.isRequired && p.reviewer.vote < 5).isNotEmpty;

  bool get hasAutoCompleteOn => prDetail.value?.data?.pr.autoCompleteSetBy != null;

  String get prStatus {
    final pr = prDetail.value?.data?.pr;
    if (pr == null) return '';

    if (pr.mergeStatus == MergeStatus.queued) return 'Merging';

    if (pr.isDraft && pr.status != PullRequestStatus.abandoned) return 'Draft';

    return '${pr.status}${pr.isDraft ? ' (draft)' : ''}';
  }

  bool get isMerging => prDetail.value?.data?.pr.mergeStatus == MergeStatus.queued;

  bool canBeReactivated = true;

  final showCommentField = ValueNotifier<bool>(false);
  final historyKey = GlobalKey();

  var _isDisposed = false;

  Timer? _timer;

  void dispose() {
    _isDisposed = true;
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> init() async {
    await _init();

    if (prDetail.value?.data == null) return;

    final mergeStatus = prDetail.value!.data?.pr.mergeStatus;

    // auto refresh page every 5 seconds until merge is completed
    if (mergeStatus == MergeStatus.queued) {
      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        await _init();
        if (prDetail.value!.data?.pr.mergeStatus != MergeStatus.queued) {
          timer.cancel();
        }
      });
    }
  }

  Future<void> _init() async {
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
      if (descriptor != null) revs.add((reviewer: r, descriptor: descriptor));
    }

    reviewers = [...revs];

    final changes = res.data?.changes ?? <CommitWithChangeEntry>[];
    if (changes.isNotEmpty) _getChangedFiles(changes);

    final conflicts = res.data?.conflicts ?? <Conflict>[];
    if (conflicts.isNotEmpty) _getConflictingFiles(conflicts);

    if (pr?.status == PullRequestStatus.abandoned) {
      canBeReactivated = await _checkIfCanBeReactivated(pr!);
    }

    final prAndThreads = await getReplacedPrAndThreads(
      basePath: apiService.basePath,
      projectId: args.project,
      data: res.data,
      getIdentity: (mention) => apiService.getIdentityFromGuid(guid: mention),
    );

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

  Future<void> goToFileDiff({
    ChangedFileDiff? diff,
    bool isAdded = false,
    bool isDeleted = false,
    String? filePath,
  }) async {
    final commits = prDetail.value!.data!.updates.whereType<IterationUpdate>().expand((u) => u.commits);
    final latestCommit = commits.isEmpty ? null : commits.first;
    final secondLatestCommit = commits.length < 2 ? null : commits.skip(1).first;

    final commitId = diff?.commitId ?? latestCommit?.commitId;
    final parent = diff?.parentCommitId ?? latestCommit?.parents?.firstOrNull ?? secondLatestCommit?.commitId;

    final basePath = '${apiService.basePath}/${args.project}';
    final repository = args.repository;

    final commit = c.Commit(
      commitId: commitId,
      parents: parent != null ? [parent] : null,
      remoteUrl: '$basePath/_git/$repository/commit/$commitId',
      url: '$basePath/_apis/git/repositories/$repository/commits/$commitId',
    );

    await AppRouter.goToFileDiff(
      (
        commit: commit,
        filePath: diff?.path ?? filePath!,
        isAdded: isAdded,
        isDeleted: isDeleted,
        pullRequestId: args.id
      ),
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
    return _editPr(status: PullRequestStatus.completed);
  }

  Future<void> abandon() async {
    return _editPr(status: PullRequestStatus.abandoned);
  }

  Future<void> reactivate() async {
    // sending isDraft in the request body causes a Bad Request error with an abandoned PR
    return _editPr(status: PullRequestStatus.active, setIsDraft: false);
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

    logAnalytics('pr_vote', {
      'vote': vote,
      'is_error': res.isError,
    });

    if (res.isError) {
      final errorMsg = _getErrorMessage(res);
      await OverlayService.error('Error', description: errorMsg);
      return;
    }

    await _showInterstitialAd();

    await init();
  }

  Future<void> _editPr({PullRequestStatus? status, bool? isDraft, bool? autocomplete, bool setIsDraft = true}) async {
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

    if (status == PullRequestStatus.completed || (autocomplete ?? false)) {
      completionOptions = await _getCompletionOptions();
      if (completionOptions == null) return;
    }

    final commitId = prDetail.value!.data!.changes.last.iteration.sourceRefCommit.commitId;

    final res = await apiService.editPullRequest(
      projectName: args.project,
      repositoryId: args.repository,
      id: args.id,
      status: status,
      isDraft: !setIsDraft ? null : (isDraft ?? prDetail.value!.data!.pr.isDraft),
      commitId: commitId,
      autocomplete: autocomplete,
      completionOptions: completionOptions,
    );

    logAnalytics('pr_edit', {
      if (status != null) 'status': status.name,
      if (isDraft != null) 'isDraft': isDraft,
      if (autocomplete != null) 'autocomplete': autocomplete,
      'is_error': res.isError,
    });

    if (res.isError) {
      final errorMsg = _getErrorMessage(res);
      await OverlayService.error('Error', description: errorMsg);
      return;
    }

    await _showInterstitialAd();

    await init();
  }

  String _getErrorMessage(ApiResponse<bool> res) {
    var errorMsg = 'Pull request not edited.';

    try {
      final responseBody = res.errorResponse?.body ?? '';
      if (responseBody.isEmpty) return errorMsg;

      final apiErrorMessage = jsonDecode(responseBody) as Map<String, dynamic>;
      final msg = apiErrorMessage['message'] as String? ?? '';

      errorMsg += '\n${msg.split(':').lastOrNull?.trim()}';

      final type = apiErrorMessage['typeKey'] as String? ?? '';
      if (type == 'GitPullRequestStaleException') {
        errorMsg += '\n\nTry to refresh the page and edit the pull request again.';
      }
    } catch (e, s) {
      logError(e, s);
    }

    return errorMsg;
  }

  // ignore: long-method
  Future<PullRequestCompletionOptions?> _getCompletionOptions() async {
    final policies = prDetail.value?.data?.policies ?? [];
    final mergeStrategyPolicy =
        policies.where((p) => p.configuration?.type?.id == _requireMergeStrategyId).firstOrNull?.configuration;

    final hasMergePolicy =
        mergeStrategyPolicy != null && !mergeStrategyPolicy.isDeleted && mergeStrategyPolicy.isEnabled;

    final mergeStrategySettings = hasMergePolicy ? mergeStrategyPolicy.settings : null;

    final mergeTypes = {
      1: (text: 'Merge (no fast forward)', isAllowed: mergeStrategySettings?.allowNoFastForward ?? true),
      2: (text: 'Squash commit', isAllowed: mergeStrategySettings?.allowSquash ?? true),
      3: (text: 'Rebase and fast-forward', isAllowed: mergeStrategySettings?.allowRebase ?? true),
      4: (text: 'Semi-linear merge', isAllowed: mergeStrategySettings?.allowRebaseMerge ?? true),
    };

    final allowedMergeType =
        mergeTypes.entries.firstWhereOrNull((entry) => entry.value.isAllowed) ?? mergeTypes.entries.first;

    var mergeType = allowedMergeType.key;
    var completeWorkItems = false;
    var deleteSourceBranch = false;
    var customizeCommitMessage = false;
    String? commitMessage;

    final branchesRes = await apiService.getRepositoryBranches(projectName: args.project, repoName: args.repository);
    final branch = (branchesRes.data ?? []).firstWhereOrNull((b) => b.name == prDetail.value!.data!.pr.sourceBranch);
    final canDeleteBranch = !(branch?.isBaseVersion ?? false);

    final mergeTypeFieldController = TextEditingController(text: allowedMergeType.value.text);

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
                        text: '',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value.text,
                              style: context.textTheme.titleSmall!.copyWith(
                                color:
                                    entry.value.isAllowed ? null : context.colorScheme.onPrimary.withValues(alpha: .4),
                              ),
                            ),
                            if (!entry.value.isAllowed)
                              Text(
                                'Forbidden by policy',
                                style: context.textTheme.labelSmall!.copyWith(color: context.colorScheme.error),
                              ),
                          ],
                        ),
                        onTap: () {
                          if (!entry.value.isAllowed) return;

                          mergeTypeFieldController.text = entry.value.text;
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

  void onHistoryVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0 && !showCommentField.value) {
      showCommentField.value = true;
    } else if (!_isDisposed && info.visibleFraction == 0 && showCommentField.value) {
      showCommentField.value = false;
    }
  }

  Future<void> addComment({int? threadId, int? parentCommentId}) async {
    final editorController = HtmlEditorController();
    final editorGlobalKey = GlobalKey<State>();

    final hasConfirmed = await showEditor(
      editorController,
      editorGlobalKey,
      title: 'Add comment',
    );
    if (!hasConfirmed) return;

    final comment = await getTextFromEditor(editorController);
    if (comment == null) return;

    final newComment = translateMentionsFromHtmlToMarkdown(comment);

    final res = await apiService.addPullRequestComment(
      projectName: args.project,
      pullRequestId: args.id,
      threadId: threadId,
      text: newComment,
      parentCommentId: parentCommentId,
      repositoryId: args.repository,
    );

    logAnalytics('add_pr_comment', {
      'comment_length': comment.length,
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not added');
    }

    await _showInterstitialAd();

    await init();
  }

  Future<void> editComment(PrComment comment, {required int threadId}) async {
    final editorController = HtmlEditorController();
    final editorGlobalKey = GlobalKey<State>();

    final hasConfirmed = await showEditor(
      editorController,
      editorGlobalKey,
      initialText: comment.content,
      title: 'Edit comment',
    );
    if (!hasConfirmed) return;

    final text = await getTextFromEditor(editorController);
    if (text == null) return;

    final newComment = translateMentionsFromHtmlToMarkdown(text);

    final res = await apiService.editPullRequestComment(
      projectName: args.project,
      repositoryId: args.repository,
      pullRequestId: args.id,
      threadId: threadId,
      comment: comment,
      text: newComment,
    );

    logAnalytics('edit_pr_comment', {
      'comment_length': newComment.length,
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not edited');
    }

    await _showInterstitialAd();

    await init();
  }

  Future<void> deleteComment(PrComment comment, {required int threadId}) async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to delete this comment?',
    );
    if (!confirm) return;

    final res = await apiService.deletePullRequestComment(
      projectName: args.project,
      repositoryId: args.repository,
      pullRequestId: args.id,
      threadId: threadId,
      comment: comment,
    );

    logAnalytics('delete_pr_comment', {
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not deleted');
    }

    await _showInterstitialAd();

    await init();
  }

  bool canEditPrComment(PrComment c) {
    return apiService.user?.emailAddress == c.author.uniqueName;
  }

  Future<void> setStatus(ThreadUpdate thread, ThreadStatus s) async {
    final res = await apiService.editPullRequestThreadStatus(
      projectName: args.project,
      repositoryId: args.repository,
      pullRequestId: args.id,
      threadId: thread.id,
      status: s,
    );

    if (!(res.data ?? false)) return OverlayService.snackbar('Status not updated', isError: true);

    await init();
  }

  Future<void> _showInterstitialAd() async {
    await ads.showInterstitialAd();
  }
}

typedef _RevWithDescriptor = ({Reviewer reviewer, String descriptor});

class MergeStatus {
  static const queued = 'queued';
}
