part of repository_detail;

class _RepositoryDetailScreen extends StatelessWidget {
  const _RepositoryDetailScreen(this.ctrl, this.parameters);

  final _RepositoryDetailController ctrl;
  final _RepositoryDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<List<RepoItem>?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: (ctrl.args.filePath?.startsWith('/') ?? false ? ctrl.args.filePath?.substring(1) : ctrl.args.filePath) ??
          ctrl.args.repositoryName,
      notifier: ctrl.repoItems,
      onEmpty: (_) => Text('No repo found'),
      builder: (items) {
        final pathPrefix = ctrl.args.filePath != null ? '${ctrl.args.filePath}' : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FilterMenu(
                  title: 'Branch',
                  values: ctrl.branches,
                  currentFilter: ctrl.currentBranch,
                  onSelected: ctrl.changeBranch,
                  formatLabel: (b) => '${b!.name} ${b.isBaseVersion ? '(default)' : ''}',
                  isDefaultFilter: false,
                ),
                const Spacer(),
                if (ctrl.currentBranch != null && ctrl.currentBranch!.behindCount > 0) ...[
                  Icon(
                    Icons.remove,
                    size: 12,
                    color: Colors.red,
                  ),
                  Text(
                    ctrl.currentBranch!.behindCount.toString(),
                    style: context.textTheme.titleSmall!.copyWith(color: Colors.red),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                if (ctrl.currentBranch != null && ctrl.currentBranch!.aheadCount > 0) ...[
                  Icon(
                    DevOpsIcons.plus,
                    size: 12,
                    color: Colors.green,
                  ),
                  Text(
                    ctrl.currentBranch!.aheadCount.toString(),
                    style: context.textTheme.titleSmall!.copyWith(color: Colors.green),
                  ),
                ],
              ],
            ),
            ...items!
                .where((i) => i.isFolder && i.path != pathPrefix && i.path != '/')
                .sorted((a, b) => a.path.compareTo(b.path))
                .where((i) => i.isFolder)
                .followedBy(
                  items.where((i) => !i.isFolder).sorted((a, b) => a.path.compareTo(b.path)),
                )
                .map(
                  (i) => InkWell(
                    onTap: () => ctrl.goToItem(i),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: i.isFolder ? context.colorScheme.surface : null,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              i.path.replaceFirst('$pathPrefix/', ''),
                              style: context.textTheme.titleSmall!
                                  .copyWith(decoration: i.isFolder ? null : TextDecoration.underline),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
