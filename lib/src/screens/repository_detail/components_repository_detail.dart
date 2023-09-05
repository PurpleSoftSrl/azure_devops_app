part of repository_detail;

class _BranchRow extends StatelessWidget {
  const _BranchRow({required this.ctrl});

  final _RepositoryDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (ctrl.currentBranch != null)
          FilterMenu(
            title: 'Branch',
            values: ctrl.branches,
            currentFilter: ctrl.currentBranch,
            onSelected: ctrl.changeBranch,
            formatLabel: (b) => b == null ? '-' : '${b.name} ${b.isBaseVersion ? '(default)' : ''}',
            isDefaultFilter: false,
            widgetBuilder: (_) => const Icon(DevOpsIcons.merge),
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
    );
  }
}
