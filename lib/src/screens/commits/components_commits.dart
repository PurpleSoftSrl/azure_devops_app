part of commits;

class _RepositoryFilterBody extends StatelessWidget {
  const _RepositoryFilterBody({
    required this.repositories,
    required this.onTap,
    required this.selectedRepository,
  });

  final List<GitRepository> repositories;
  final void Function(GitRepository?) onTap;
  final GitRepository? selectedRepository;

  @override
  Widget build(BuildContext context) {
    final groupedRepos = groupBy(repositories, (r) => r.project!.name!);
    return ListView(
      children: [
        _RepositoryRow(
          onTap: onTap,
          repository: null,
          selectedRepository: selectedRepository,
        ),
        const Divider(
          height: 24,
        ),
        ...groupedRepos.entries.map((entry) {
          final projectName = entry.key;
          final repos = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectName,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...repos.map(
                (repo) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      _RepositoryRow(
                        repository: repo,
                        selectedRepository: selectedRepository,
                        onTap: onTap,
                      ),
                      if (repo != repos.last)
                        const Divider(
                          height: 24,
                        )
                      else
                        const SizedBox(
                          height: 24,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),
      ],
    );
  }
}

class _RepositoryRow extends StatelessWidget {
  const _RepositoryRow({
    required this.repository,
    required this.selectedRepository,
    required this.onTap,
  });

  final GitRepository? repository;
  final GitRepository? selectedRepository;
  final void Function(GitRepository?) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = (repository == null && selectedRepository == null) || (repository?.id == selectedRepository?.id);
    return InkWell(
      onTap: () {
        AppRouter.popRoute();
        onTap(repository);
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 2.5,
            backgroundColor: context.themeExtension.onBackground,
          ),
          const SizedBox(width: 8),
          Text(
            repository == null ? 'All' : repository!.name!,
            style:
                context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, fontFamily: AppTheme.defaultFont),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(DevOpsIcons.success),
          ],
        ],
      ),
    );
  }
}
