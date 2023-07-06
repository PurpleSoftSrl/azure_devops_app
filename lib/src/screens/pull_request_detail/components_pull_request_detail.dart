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
    final threads = prWithDetails.threads;
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
            if (threads.isNotEmpty) ...[
              SectionHeader(text: 'History'),
              ...threads.sortedBy((t) => t.publishedDate).reversed.map(
                    (t) => Column(
                      children: [
                        ...t.comments.sortedBy((c) => c.publishedDate).map(
                              (c) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: switch (t.properties?.type?.value) {
                                        'VoteUpdate' => Row(
                                            children: [
                                              if (c.content.voteIcon != null) ...[
                                                c.content.voteIcon!,
                                                const SizedBox(width: 10),
                                              ],
                                              _UserAvatar(commit: c, thread: t),
                                              Expanded(
                                                child: Text(
                                                  '${c.author.displayName} ${c.content.voteDescription}',
                                                ),
                                              ),
                                            ],
                                          ),
                                        'StatusUpdate' when pr.status == PullRequestState.completed => Row(
                                            children: [
                                              _UserAvatar(commit: c, thread: t),
                                              Expanded(
                                                child: Text(
                                                  '${t.identities?.entries.firstOrNull?.value['displayName'] ?? c.author.displayName} completed the pull request',
                                                ),
                                              ),
                                            ],
                                          ),
                                        'RefUpdate' => _RefUpdateWidget(ctrl: ctrl, thread: t),
                                        _ when c.commentType == 'text' => _CommentWidget(ctrl: ctrl, commit: c),
                                        _ => Row(
                                            children: [
                                              _UserAvatar(commit: c, thread: t),
                                              Expanded(child: Text(c.content)),
                                            ],
                                          ),
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    Text(c.publishedDate.minutesAgo),
                                  ],
                                ),
                              ),
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
          if (ctrl.addedFilesCount > 0) ...[
            Text(
              '${ctrl.addedFilesCount} added file${ctrl.addedFilesCount == 1 ? '' : 's'}',
              style: context.textTheme.titleLarge,
            ),
            _GroupedFiles(
              groupedFiles: ctrl.groupedAddedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff, isAdded: true),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
          if (ctrl.editedFilesCount > 0) ...[
            Text(
              '${ctrl.editedFilesCount} edited file${ctrl.editedFilesCount == 1 ? '' : 's'}',
              style: context.textTheme.titleLarge,
            ),
            _GroupedFiles(
              groupedFiles: ctrl.groupedEditedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
          if (ctrl.deletedFilesCount > 0) ...[
            Text(
              '${ctrl.deletedFilesCount} deleted file${ctrl.deletedFilesCount == 1 ? '' : 's'}',
              style: context.textTheme.titleLarge,
            ),
            _GroupedFiles(
              groupedFiles: ctrl.groupedDeletedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff, isDeleted: true),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.commit, required this.thread});

  final Comment commit;
  final Thread thread;

  @override
  Widget build(BuildContext context) {
    if ((commit.author.uniqueName.isEmpty) && (thread.identities ?? {}).isEmpty) {
      return const SizedBox();
    }

    return Row(
      children: [
        if (commit.author.uniqueName.isNotEmpty) ...[
          MemberAvatar(userDescriptor: commit.author.descriptor, radius: 20),
          const SizedBox(width: 10),
        ] else if ((thread.identities ?? {}).isNotEmpty) ...[
          MemberAvatar(userDescriptor: thread.identities!.values.first['descriptor']?.toString() ?? '', radius: 20),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _CommentWidget extends StatelessWidget {
  const _CommentWidget({required this.ctrl, required this.commit});

  final _PullRequestDetailController ctrl;
  final Comment commit;

  @override
  Widget build(BuildContext context) {
    final isEdited = commit.publishedDate.isBefore(commit.lastUpdatedDate);
    final isReply = commit.parentCommentId > 0;
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
              MemberAvatar(userDescriptor: commit.author.descriptor, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: commit.author.displayName),
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
            data: commit.content,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(p: context.textTheme.titleSmall),
            onTapLink: ctrl.onTapMarkdownLink,
          ),
        ],
      ),
    );
  }
}

class _RefUpdateWidget extends StatelessWidget {
  const _RefUpdateWidget({required this.ctrl, required this.thread});

  final _PullRequestDetailController ctrl;
  final Thread thread;

  @override
  Widget build(BuildContext context) {
    final commits = ctrl.getCommits(thread) ?? [];
    final committerDescriptor = ctrl.getCommitterDescriptor(thread);
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
              ctrl.getCommitIteration(thread)?.toString() ?? '-',
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
                  if (committerDescriptor != null) ...[
                    MemberAvatar(
                      userDescriptor: committerDescriptor,
                      radius: 15,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      ctrl.getRefUpdateTitle(thread),
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
                          if (ctrl.getCommitterDescriptorFromEmail(c.author?.email) != null) ...[
                            MemberAvatar(
                              userDescriptor: ctrl.getCommitterDescriptorFromEmail(c.author?.email)!,
                              radius: 15,
                            ),
                          ],
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

class _GroupedFiles extends StatelessWidget {
  const _GroupedFiles({required this.groupedFiles, required this.onTap});

  final Map<String, Set<_ChangedFileDiff>> groupedFiles;
  final dynamic Function(_ChangedFileDiff) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedFiles.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              if (entry.key != '/') Text(entry.key.startsWith('/') ? entry.key.substring(1) : entry.key),
              ...entry.value.map(
                (fileName) => InkWell(
                  onTap: () => onTap(fileName),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 5),
                    child: Text(
                      fileName.fileName,
                      style: context.textTheme.titleSmall!.copyWith(
                        color: context.colorScheme.onSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
