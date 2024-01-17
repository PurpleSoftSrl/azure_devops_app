part of profile;

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen(this.ctrl, this.parameters);

  final _ProfileController ctrl;
  final _ProfileParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<Commit>?>(
      init: ctrl.init,
      title: 'Profile',
      notifier: ctrl.recentCommits,
      showScrollbar: true,
      builder: (commits) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ctrl.author?.descriptor != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    ctrl.author!.displayName!,
                    style: context.textTheme.headlineLarge,
                  ),
                ),
                MemberAvatar(
                  userDescriptor: ctrl.author!.descriptor,
                  radius: 60,
                  tappable: false,
                ),
              ],
            ),
          ],
          if (ctrl.todaysCommitsPerRepo.isNotEmpty || ctrl.myWorkItems.isNotEmpty) ...[
            SectionHeader(text: "Today's summary"),
            Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              padding: const EdgeInsets.all(20),
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ctrl.todaysCommitsPerRepo.isNotEmpty) ...[
                    Text(
                      ctrl.getCommitsSummary(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.onSecondary),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    ...ctrl.todaysCommitsPerRepo.entries
                        .sortedBy<num>((e) => e.value.values.expand((e1) => e1).length)
                        .reversed
                        .map(
                          (p) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: p.value.entries
                                .sortedBy<num>((e) => e.value.length)
                                .map(
                                  (e) => InkWell(
                                    onTap: () => ctrl.goToCommits(e.value.first),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${e.value.length}',
                                              style: context.textTheme.bodyMedium!
                                                  .copyWith(decoration: TextDecoration.underline),
                                            ),
                                            TextSpan(
                                              text: ' in ',
                                              style:
                                                  context.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w200),
                                            ),
                                            TextSpan(
                                              text: e.key,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                  ],
                  if (ctrl.myWorkItems.isNotEmpty) ...[
                    if (ctrl.todaysCommitsPerRepo.isNotEmpty)
                      const SizedBox(
                        height: 10,
                      ),
                    Text(
                      ctrl.getWorkItemsSummary(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.onSecondary),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    ...ctrl.myWorkItems.map(
                      (item) => InkWell(
                        onTap: () => ctrl.goToWorkItemDetail(item),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '#${item.id}',
                                  style: context.textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline),
                                ),
                                TextSpan(
                                  text: ' in ',
                                  style: context.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w200),
                                ),
                                TextSpan(
                                  text: '${item.fields.systemTeamProject} (${item.fields.systemState})',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          SectionHeader.withIcon(
            text: 'Recent commits',
            icon: DevOpsIcons.commit,
          ),
          if (commits!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text('No commits found')),
            )
          else
            ...commits.map(
              (c) => CommitListTile(
                commit: c,
                showAuthor: false,
                onTap: () => ctrl.goToCommitDetail(c),
                isLast: c == commits.last,
              ),
            ),
        ],
      ),
    );
  }
}
