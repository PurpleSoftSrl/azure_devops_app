part of project_detail;

class _ProjectDetailScreen extends StatelessWidget {
  const _ProjectDetailScreen(this.ctrl, this.parameters);

  final _ProjectDetailController ctrl;
  final _ProjectDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<Project?>(
      init: ctrl.init,
      onLoading: ctrl.loadMore,
      dispose: ctrl.dispose,
      title: ctrl.projectName,
      notifier: ctrl.project,
      onEmpty: (_) => Text('No projects found'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder(
            valueListenable: ctrl.project,
            builder: (_, project, __) =>
                project?.data?.defaultTeam?.id != null && ctrl.apiService.organization.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${ctrl.apiService.basePath}/_apis/GraphProfile/MemberAvatars/${project!.data!.defaultTeam!.id}?overrideDisplayName=${project.data!.name}&size=large',
                          httpHeaders: ctrl.apiService.headers,
                          errorWidget: (_, __, ___) => const SizedBox(),
                        ),
                      )
                    : const SizedBox(),
          ),
        ),
      ],
      builder: (project) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project!.description != null) ...[
            Text(
              project.description!,
              style: context.textTheme.bodyLarge,
            ),
            SectionHeader.withIcon(
              text: project.defaultTeam!.name,
              icon: DevOpsIcons.users,
            ),
          ] else if (ctrl.members.isNotEmpty) ...[
            SectionHeader.noMargin(
              text: project.defaultTeam!.name,
              icon: DevOpsIcons.users,
            ),
            Wrap(
              children: ctrl.members
                  .map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 12),
                      child: Column(
                        children: [
                          MemberAvatar(
                            userDescriptor: m.identity!.descriptor!,
                            radius: 50,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            m.identity!.displayName!.split(' ').first,
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (ctrl.meaningfulLanguages.isNotEmpty) ...[
            SectionHeader.withIcon(
              text: 'Languages',
              icon: DevOpsIcons.languages,
            ),
            Wrap(
              children: ctrl.meaningfulLanguages
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Chip(
                        label: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${r.name}    ',
                                style: context.textTheme.labelMedium!.copyWith(color: context.colorScheme.onBackground),
                              ),
                              TextSpan(
                                text: '${r.languagePercentage?.round()}%',
                                style: context.textTheme.labelMedium!.copyWith(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (ctrl.repos.isNotEmpty) ...[
            SectionHeader.withIcon(
              text: 'Repositories',
              icon: DevOpsIcons.repository,
            ),
            ...ctrl.repos.map(
              (r) => InkWell(
                onTap: () => ctrl.goToRepoDetail(r),
                child: Container(
                  margin: r == ctrl.repos.first ? null : const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(r.name!)),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (ctrl.pullRequests.isNotEmpty) ...[
            SectionHeader.withIcon(
              text: 'Pull requests',
              icon: DevOpsIcons.pullrequest,
            ),
            ...ctrl.pullRequests.map(
              (pr) => PullRequestListTile(
                pr: pr,
                onTap: () => ctrl.goToPullRequestDetail(pr),
                isLast: pr == ctrl.pullRequests.last,
              ),
            ),
          ],
          if (ctrl.pipelines.value.isNotEmpty) ...[
            SectionHeader.withIcon(
              text: 'Recent pipelines',
              icon: DevOpsIcons.pipeline,
            ),
            ValueListenableBuilder(
              valueListenable: ctrl.pipelines,
              builder: (_, pipelines, __) => Column(
                children: ctrl.pipelines.value
                    .map(
                      (p) => PipelineListTile(
                        pipe: p,
                        onTap: () => ctrl.goToPipelineDetail(p),
                        isLast: p == ctrl.pipelines.value.last,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
