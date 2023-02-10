part of profile;

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen(this.ctrl, this.parameters);

  final _ProfileController ctrl;
  final _ProfileParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<List<Commit>?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Profile',
      notifier: ctrl.recentCommits,
      onEmpty: (_) => Text('No commits found'),
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
                  userDescriptor: ctrl.author!.descriptor!,
                  radius: 60,
                  tappable: false,
                ),
              ],
            ),
          ],
          if (ctrl.todaysCommitsPerRepo.isNotEmpty) ...[
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
                  Text(
                    ctrl.getSummary(),
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ...ctrl.todaysCommitsPerRepo.entries.map(
                    (p) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...p.value.entries.map(
                          (e) => Text('${e.key} ${e.value.length}'),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SectionHeader.withIcon(
            text: 'Recent commits',
            icon: DevOpsIcons.commit,
          ),
          ...commits!.map(
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
