part of member_detail;

class _MemberDetailScreen extends StatelessWidget {
  const _MemberDetailScreen(this.ctrl, this.parameters);

  final _MemberDetailController ctrl;
  final _MemberDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<GraphUser?>(
      init: ctrl.init,
      title: 'User detail',
      notifier: ctrl.user,
      builder: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: MemberAvatar(
              userDescriptor: ctrl.userDescriptor,
              radius: 100,
              tappable: false,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          TextTitleDescription(
            title: 'Name: ',
            description: user!.displayName!,
          ),
          Link(
            uri: Uri.parse('mailto:${user.mailAddress}'),
            builder: (_, link) => SizedBox(
              height: 48,
              child: InkWell(
                onTap: link,
                child: Row(
                  children: [
                    TextTitleDescription(
                      title: 'Email: ',
                      description: user.mailAddress!,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Icon(DevOpsIcons.mail),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ValueListenableBuilder(
            valueListenable: ctrl.recentCommits,
            builder: (_, commits, _) {
              if (commits == null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(child: const CircularProgressIndicator()),
                );
              }

              if (commits.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                    child: Text('No commits found'),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader.withIcon(
                    text: 'Recent commits',
                    icon: DevOpsIcons.commit,
                  ),
                  ...commits.map(
                    (c) => CommitListTile(
                      commit: c,
                      showAuthor: false,
                      onTap: () => ctrl.goToCommitDetail(c),
                      isLast: c == commits.last,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
