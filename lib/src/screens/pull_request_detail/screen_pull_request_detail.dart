part of pull_request_detail;

class _PullRequestDetailScreen extends StatelessWidget {
  const _PullRequestDetailScreen(this.ctrl, this.parameters);

  final _PullRequestDetailController ctrl;
  final _PullRequestDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<PullRequest?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Pull request',
      notifier: ctrl.prDetail,
      actions: [
        IconButton(
          onPressed: ctrl.sharePr,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      builder: (pr) => DefaultTextStyle(
        style: context.textTheme.titleSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextTitleDescription(title: 'Id: ', description: pr!.pullRequestId.toString()),
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
            Row(
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
                onTapLink: (text, href, title) async {
                  if (await canLaunchUrlString(href!)) await launchUrlString(href);
                },
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
          ],
        ),
      ),
    );
  }
}
