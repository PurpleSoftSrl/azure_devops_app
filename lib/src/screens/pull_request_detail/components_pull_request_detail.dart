part of pull_request_detail;

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
