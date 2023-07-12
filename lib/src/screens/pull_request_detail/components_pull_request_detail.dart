part of pull_request_detail;

class _PageTabs extends StatelessWidget {
  const _PageTabs({
    required this.ctrl,
    required this.visiblePage,
    required this.prWithDetails,
  });

  final _PullRequestDetailController ctrl;
  final int visiblePage;
  final PullRequestWithDetails prWithDetails;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: visiblePage,
      children: [
        _PullRequestOverview(ctrl: ctrl, visiblePage: visiblePage, prWithDetails: prWithDetails),
        _PullRequestChangedFiles(ctrl: ctrl, visiblePage: visiblePage),
        _PullRequestCommits(ctrl: ctrl, visiblePage: visiblePage, prWithDetails: prWithDetails),
      ],
    );
  }
}

class _PullRequestOverview extends StatelessWidget {
  const _PullRequestOverview({
    required this.ctrl,
    required this.visiblePage,
    required this.prWithDetails,
  });

  final _PullRequestDetailController ctrl;
  final int visiblePage;
  final PullRequestWithDetails prWithDetails;

  @override
  Widget build(BuildContext context) {
    final pr = prWithDetails.pr;
    return Visibility(
      visible: visiblePage == 0,
      child: DefaultTextStyle(
        style: context.textTheme.titleSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextTitleDescription(title: 'Id: ', description: pr.pullRequestId.toString()),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                ),
                Text(
                  pr.status.toString(),
                  style: context.textTheme.titleSmall!.copyWith(color: pr.status.color),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                TextTitleDescription(title: 'Created by: ', description: pr.createdBy.displayName),
                const SizedBox(
                  width: 20,
                ),
                MemberAvatar(
                  userDescriptor: pr.createdBy.descriptor,
                  radius: 20,
                ),
                const Spacer(),
                Text(pr.creationDate.minutesAgo),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ProjectChip(
              onTap: ctrl.goToProject,
              projectName: pr.repository.project.name,
            ),
            RepositoryChip(
              onTap: ctrl.goToRepo,
              repositoryName: pr.repository.name,
            ),
            Wrap(
              children: [
                TextTitleDescription(title: 'From: ', description: pr.sourceBranch),
                const SizedBox(
                  width: 20,
                ),
                TextTitleDescription(title: 'To: ', description: pr.targetBranch),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            if (prWithDetails.conflicts.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: context.colorScheme.error, width: 2),
                ),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: GroupedFiles(
                  bottomSpace: false,
                  groupedFiles: ctrl.groupedConflictingFiles,
                ),
              ),
            ],
            Text(
              'Title: ',
              style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
            ),
            Text(pr.title),
            const SizedBox(
              height: 10,
            ),
            if (pr.description != null && pr.description!.isNotEmpty) ...[
              Text(
                'Description: ',
                style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
              ),
              MarkdownBody(
                data: '${pr.description}',
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(p: context.textTheme.titleSmall),
                onTapLink: ctrl.onTapMarkdownLink,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
            if (pr.mergeStatus != null && pr.mergeStatus!.isNotEmpty)
              TextTitleDescription(title: 'Merge status: ', description: '${pr.mergeStatus}'),
            const SizedBox(
              height: 10,
            ),
            TextTitleDescription(title: 'Created at: ', description: pr.creationDate.toSimpleDate()),
            if (pr.reviewers.isNotEmpty) ...[
              SectionHeader(text: 'Reviewers'),
              ...pr.reviewers.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      MemberAvatar(
                        userDescriptor: ctrl.reviewers.firstWhere((rev) => rev.reviewer.id == r.id).descriptor,
                        radius: 20,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(r.displayName),
                      if (r.isRequired) Text(' (required)'),
                      const Spacer(),
                      if (r.vote > 0)
                        Icon(
                          DevOpsIcons.success,
                          color: Colors.green,
                        )
                      else if (r.vote < 0)
                        Icon(
                          DevOpsIcons.failed,
                          color: context.colorScheme.error,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (prWithDetails.updates.isNotEmpty) ...[
              SectionHeader(text: 'History'),
              ...prWithDetails.updates.map(
                (u) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: switch (u) {
                            VoteUpdate() => Row(
                                children: [
                                  if (u.content.voteIcon != null) ...[
                                    u.content.voteIcon!,
                                    const SizedBox(width: 10),
                                  ],
                                  _UserAvatar(update: u),
                                  Expanded(child: Text('${u.author.displayName} ${u.content.voteDescription}')),
                                ],
                              ),
                            StatusUpdate() when pr.status == PullRequestState.completed => Row(
                                children: [
                                  _UserAvatar(update: u),
                                  Expanded(
                                    child: Text(
                                      '${u.identity['displayName'] ?? u.author.displayName} completed the pull request',
                                    ),
                                  ),
                                ],
                              ),
                            IterationUpdate() => _RefUpdateWidget(ctrl: ctrl, iteration: u),
                            CommentUpdate() => _CommentWidget(ctrl: ctrl, comment: u),
                            SystemUpdate() ||
                            _ =>
                              Row(children: [_UserAvatar(update: u), Expanded(child: Text(u.content))])
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(u.date.minutesAgo),
                      ],
                    ),
                    const Divider(height: 30),
                  ],
                ),
              ),
              Row(
                children: [
                  MemberAvatar(userDescriptor: pr.createdBy.descriptor, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${pr.createdBy.displayName} created the pull request')),
                  Text(pr.creationDate.minutesAgo),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PullRequestChangedFiles extends StatelessWidget {
  const _PullRequestChangedFiles({
    required this.visiblePage,
    required this.ctrl,
  });

  final int visiblePage;
  final _PullRequestDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visiblePage == 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ctrl.addedFilesCount > 0)
            GroupedFiles(
              groupedFiles: ctrl.groupedAddedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff, isAdded: true),
            ),
          if (ctrl.editedFilesCount > 0)
            GroupedFiles(
              groupedFiles: ctrl.groupedEditedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff),
            ),
          if (ctrl.deletedFilesCount > 0)
            GroupedFiles(
              groupedFiles: ctrl.groupedDeletedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff, isDeleted: true),
            ),
        ],
      ),
    );
  }
}

class _PullRequestCommits extends StatelessWidget {
  const _PullRequestCommits({
    required this.visiblePage,
    required this.ctrl,
    required this.prWithDetails,
  });

  final int visiblePage;
  final _PullRequestDetailController ctrl;
  final PullRequestWithDetails prWithDetails;

  @override
  Widget build(BuildContext context) {
    final commits = prWithDetails.updates.whereType<IterationUpdate>().expand((u) => u.commits);
    return Visibility(
      visible: visiblePage == 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...commits.map(
            (commit) => CommitListTile(
              onTap: () => ctrl.goToCommitDetail(commit.commitId!),
              commit: commit.copyWith(
                remoteUrl:
                    '${ctrl.apiService.basePath}/${prWithDetails.pr.repository.project.name}/_git/${prWithDetails.pr.repository.name}/commit/${commit.commitId}',
              ),
              isLast: commit == commits.last,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.update});

  final PullRequestUpdate update;

  @override
  Widget build(BuildContext context) {
    if ((update.author.uniqueName.isEmpty) && (update.identity == null)) {
      return const SizedBox();
    }

    return Row(
      children: [
        if (update.author.uniqueName.isNotEmpty) ...[
          MemberAvatar(userDescriptor: update.author.descriptor, radius: 20),
          const SizedBox(width: 10),
        ] else if (update.identity != null) ...[
          MemberAvatar(userDescriptor: update.identity['descriptor']?.toString() ?? '', radius: 20),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _CommentWidget extends StatelessWidget {
  const _CommentWidget({required this.ctrl, required this.comment});

  final _PullRequestDetailController ctrl;
  final CommentUpdate comment;

  @override
  Widget build(BuildContext context) {
    final isEdited = comment.date.isBefore(comment.updatedDate);
    final isReply = comment.parentCommentId > 0;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MemberAvatar(userDescriptor: comment.author.descriptor, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: comment.author.displayName),
                      TextSpan(
                        text: '  ${isReply ? 'replied' : 'commented'} ${isEdited ? '(edited)' : ''}',
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: comment.content,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(p: context.textTheme.titleSmall),
            onTapLink: ctrl.onTapMarkdownLink,
          ),
        ],
      ),
    );
  }
}

class _RefUpdateWidget extends StatelessWidget {
  const _RefUpdateWidget({required this.ctrl, required this.iteration});

  final _PullRequestDetailController ctrl;
  final IterationUpdate iteration;

  @override
  Widget build(BuildContext context) {
    final commits = iteration.commits;
    final committerDescriptor = iteration.author.descriptor;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: context.colorScheme.secondaryContainer,
          ),
          child: Center(
            child: Text(
              iteration.id.toString(),
              style: context.textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MemberAvatar(
                    userDescriptor: committerDescriptor,
                    radius: 15,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${iteration.author.displayName} pushed ${commits.length} commit${commits.length == 1 ? '' : 's'}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...commits.map(
                (c) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.comment ?? '-',
                      style: context.textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    DefaultTextStyle(
                      style: context.textTheme.bodySmall!,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: c.commitId == null ? null : () => ctrl.goToCommitDetail(c.commitId!),
                            child: Text(
                              c.commitId?.substring(0, 8) ?? '-',
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(decoration: c.commitId == null ? null : TextDecoration.underline),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MemberAvatar(
                            userDescriptor: committerDescriptor,
                            radius: 15,
                          ),
                          const SizedBox(width: 10),
                          Text(c.author?.name ?? ''),
                          const SizedBox(width: 10),
                          Text(c.author?.date?.minutesAgo ?? ''),
                        ],
                      ),
                    ),
                    if (commits.isNotEmpty && c != commits.last) const Divider(endIndent: 40, thickness: .5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
