part of file_diff;

class _FileDiffController with ShareMixin, AppLogger, PullRequestHelper {
  _FileDiffController._(this.apiService, this.args);

  final AzureApiService apiService;
  final FileDiffArgs args;

  final diff = ValueNotifier<ApiResponse<Diff?>?>(null);

  /// Used to calculate text width to avoid layout issues.
  int diffMaxLength = -1;

  String? imageDiffContent;
  String? previousImageDiffContent;

  List<ThreadUpdate> prThreads = [];

  bool get isImageDiff => imageDiffContent != null || previousImageDiffContent != null;

  Future<void> init() async {
    final res = await apiService.getCommitDiff(
      commit: args.commit,
      filePath: args.filePath,
      isAdded: args.isAdded,
      isDeleted: args.isDeleted,
    );

    if (res.data != null) {
      final maxLengthM = res.data!.blocks.map((e) => e.mLines).expand((l) => l).fold(0, (a, b) {
        final size = _getTextWidth(b);
        return a > size ? a : size;
      });

      final maxLengthO = res.data!.blocks.map((e) => e.oLines).expand((l) => l).fold(0, (a, b) {
        final size = _getTextWidth(b);
        return a > size ? a : size;
      });

      final maxLength = max(maxLengthM, maxLengthO);

      diffMaxLength = maxLength;
    }

    final isImage = res.data?.imageComparison ?? false;

    if (isImage) {
      if (!args.isDeleted) {
        final imageRes = await apiService.getFileDetail(
          projectName: args.commit.projectName,
          repoName: args.commit.repositoryName,
          path: args.filePath,
          commitId: args.commit.commitId,
        );

        imageDiffContent = imageRes.data?.content;
      }

      if (!args.isAdded) {
        final previousImageRes = await apiService.getFileDetail(
          projectName: args.commit.projectName,
          repoName: args.commit.repositoryName,
          path: args.filePath,
          commitId: args.commit.commitId,
          previousChange: true,
        );

        previousImageDiffContent = previousImageRes.data?.content;
      }
    }

    if (args.pullRequestId != null) {
      await _getPullRequestComments();
    }

    diff.value = res;
  }

  Future<void> _getPullRequestComments() async {
    final res = await apiService.getPullRequest(
      projectName: args.commit.projectName,
      repositoryId: args.commit.repositoryId,
      id: args.pullRequestId!,
    );

    final prAndThreads = await getReplacedPrAndThreads(
      basePath: apiService.basePath,
      projectId: args.commit.projectId,
      data: res.data,
      getIdentity: (mention) => apiService.getIdentityFromGuid(guid: mention),
    );

    prThreads = prAndThreads.updates
        .whereType<ThreadUpdate>()
        .where(
          (t) =>
              t.threadContext != null &&
              t.threadContext!.filePath == args.filePath &&
              t.comments.any((c) => c.commentType == 'text'),
        )
        .toList();
  }

  bool isNotRealChange(Block block) {
    return (block.truncatedAfter ?? false) || (block.truncatedBefore ?? false) || block.changeType == 0;
  }

  void shareDiff() {
    final baseUrl = '${apiService.basePath}/${args.commit.projectName}/_git/${args.commit.repositoryName}';

    final diffUrl = args.pullRequestId != null
        ? '$baseUrl/pullrequest/${args.pullRequestId}?_a=files&path=${args.filePath}'
        : '$baseUrl/commit/${args.commit.commitId}';

    shareUrl(diffUrl);
  }

  int _getTextWidth(String b) {
    return (TextPainter(
      text: TextSpan(text: b.trimRight(), style: AppRouter.navigatorKey.currentContext!.textTheme.titleSmall),
      maxLines: 1,
      textScaler: MediaQuery.of(AppRouter.navigatorKey.currentContext!).textScaler,
      textDirection: TextDirection.ltr,
    )..layout())
        .size
        .width
        .toInt();
  }

  Future<void> addPrComment({
    int? threadId,
    int? parentCommentId,
    required int lineNumber,
    required String line,
    required bool isRightFile,
  }) async {
    final editorController = HtmlEditorController();
    final editorGlobalKey = GlobalKey<State>();

    final hasConfirmed = await showEditor(
      editorController,
      editorGlobalKey,
      title: 'Add comment on line $lineNumber',
    );
    if (!hasConfirmed) return;

    final comment = await getTextFromEditor(editorController);
    if (comment == null) return;

    final newComment = translateMentionsFromHtmlToMarkdown(comment);

    final res = await apiService.addPullRequestComment(
      projectName: args.commit.projectName,
      repositoryId: args.commit.repositoryId,
      pullRequestId: args.pullRequestId!,
      threadId: threadId,
      text: newComment,
      parentCommentId: parentCommentId,
      filePath: args.filePath,
      lineNumber: lineNumber,
      lineLength: line.length + 1,
      isRightFile: isRightFile,
    );

    logAnalytics('add_pr_comment_from_file_diff', {
      'comment_length': comment.length,
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not added');
    }

    final isReply = threadId != null;

    if (isReply) {
      // close popup menu
      AppRouter.pop();
    }

    await init();
  }

  Future<void> editPrComment(PrComment comment, {required int threadId}) async {
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
      projectName: args.commit.projectName,
      repositoryId: args.commit.repositoryId,
      pullRequestId: args.pullRequestId!,
      threadId: threadId,
      comment: comment,
      text: newComment,
    );

    logAnalytics('edit_pr_comment_from_file_diff', {
      'comment_length': newComment.length,
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not edited');
    }

    AppRouter.pop();
    await init();
  }

  Future<void> deletePrComment(PrComment comment, {required int threadId}) async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to delete this comment?',
    );
    if (!confirm) return;

    final res = await apiService.deletePullRequestComment(
      projectName: args.commit.projectName,
      repositoryId: args.commit.repositoryId,
      pullRequestId: args.pullRequestId!,
      threadId: threadId,
      comment: comment,
    );

    logAnalytics('delete_pr_comment_from_file_diff', {
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not deleted');
    }

    AppRouter.pop();
    await init();
  }

  bool canEditPrComment(PrComment c) {
    return apiService.user?.emailAddress == c.author.uniqueName;
  }

  Future<void> setStatus(ThreadUpdate thread, ThreadStatus s) async {
    final res = await apiService.editPullRequestThreadStatus(
      projectName: args.commit.projectId,
      repositoryId: args.commit.repositoryId,
      pullRequestId: args.pullRequestId!,
      threadId: thread.id,
      status: s,
    );

    if (!(res.data ?? false)) return OverlayService.snackbar('Status not updated', isError: true);

    AppRouter.pop();
    await init();
  }
}
