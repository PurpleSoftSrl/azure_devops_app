part of repository_detail;

class _RepositoryDetailScreen extends StatelessWidget {
  const _RepositoryDetailScreen(this.ctrl, this.parameters);

  final _RepositoryDetailController ctrl;
  final _RepositoryDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<List<Commit>?>(
      onRefresh: ctrl.init,
      onLoading: ctrl.loadMore,
      dispose: ctrl.dispose,
      title: ctrl.args.repositoryName,
      notifier: ctrl.commits,
      onEmpty: (_) => Text('No project found'),
      builder: (commits) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader.noMargin(
            text: 'Recent commits',
          ),
          ...commits!.map(
            (c) => CommitListTile(
              commit: c,
              showRepo: false,
              onTap: () => ctrl.goToCommitDetail(c),
              isLast: c == commits.last,
            ),
          ),
        ],
      ),
    );
  }
}
