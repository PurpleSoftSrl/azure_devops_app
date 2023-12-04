part of project_detail;

class _ProjectDetailScreen extends StatelessWidget {
  const _ProjectDetailScreen(this.ctrl, this.parameters);

  final _ProjectDetailController ctrl;
  final _ProjectDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return AppPage<ProjectDetail?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: ctrl.projectName,
      notifier: ctrl.project,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder(
            valueListenable: ctrl.project,
            builder: (_, project, __) =>
                project?.data?.project.defaultTeam?.id != null && ctrl.apiService.organization.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${ctrl.apiService.basePath}/_apis/GraphProfile/MemberAvatars/${project!.data!.project.defaultTeam!.id}?overrideDisplayName=${project.data!.project.name}&size=large',
                          httpHeaders: ctrl.apiService.headers,
                          errorWidget: (_, __, ___) => const SizedBox(),
                        ),
                      )
                    : const SizedBox(),
          ),
        ),
      ],
      builder: (detail) {
        final project = detail!.project;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.description != null) ...[
              Text(
                project.description!,
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],
            if (ctrl.teamsWithMembers.isNotEmpty) ...[
              for (final team in ctrl.teamsWithMembers)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader.noMargin(
                      text: team.team.name ?? '-',
                      icon: DevOpsIcons.users,
                    ),
                    if (team.team.description?.isNotEmpty ?? false) ...[
                      Text(
                        team.team.description ?? '',
                        style: context.textTheme.labelMedium,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                    Wrap(
                      children: team.members
                          .map(
                            (m) => Container(
                              width: parameters.memberAvatarSize + 15,
                              margin: const EdgeInsets.only(right: 12, bottom: 12),
                              child: Column(
                                children: [
                                  MemberAvatar(
                                    userDescriptor: m.identity!.descriptor,
                                    radius: parameters.memberAvatarSize,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    m.identity!.displayName!.split(' ').first,
                                    style: context.textTheme.labelSmall,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (team != ctrl.teamsWithMembers.last)
                      const SizedBox(
                        height: 16,
                      ),
                  ],
                ),
            ] else
              SectionHeader.noMargin(
                text: project.defaultTeam!.name,
                icon: DevOpsIcons.users,
              ),
            if (ctrl.meaningfulLanguages.isNotEmpty) ...[
              SectionHeader.withIcon(
                text: 'Languages',
                icon: DevOpsIcons.languages,
              ),
              Wrap(
                children: ctrl.meaningfulLanguages
                    .map(
                      (r) => _StatsChip(
                        name: r.name,
                        value: '${r.languagePercentage?.round()}%',
                      ),
                    )
                    .toList(),
              ),
            ],
            SectionHeader.withIcon(
              text: 'Work',
              icon: DevOpsIcons.repository,
            ),
            GridView.count(
              crossAxisCount: 2,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: parameters.gridItemAspectRatio,
              crossAxisSpacing: 13,
              mainAxisSpacing: 18,
              children: [
                WorkCard(
                  title: 'Commits',
                  icon: DevOpsIcons.commit,
                  onTap: ctrl.goToCommits,
                  index: i++,
                ),
                WorkCard(
                  title: 'Pipelines',
                  icon: DevOpsIcons.pipeline,
                  onTap: ctrl.goToPipelines,
                  index: i++,
                ),
                WorkCard(
                  title: 'Work items',
                  icon: DevOpsIcons.task,
                  onTap: ctrl.goToWorkItems,
                  index: i++,
                ),
                WorkCard(
                  title: 'Pull requests',
                  icon: DevOpsIcons.pullrequest,
                  onTap: ctrl.goToPullRequests,
                  index: i++,
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Builder(
              builder: (context) {
                final gitMetrics = detail.gitmetrics;
                final workMetrics = detail.workMetrics;
                final pipelinesMetrics = detail.pipelinesMetrics;
                final pipeSuccess = pipelinesMetrics?.total == null || pipelinesMetrics!.total <= 0
                    ? 0
                    : (pipelinesMetrics.successful / pipelinesMetrics.total) * 100;
                final pipeSuccessStr =
                    '${pipeSuccess.toInt() == pipeSuccess ? pipeSuccess.round() : pipeSuccess.toStringAsFixed(1)}%';

                final hasWorkStats = workMetrics?.workItemsCreated != null && workMetrics!.workItemsCreated > 0;
                final hasGitStats = gitMetrics?.commitsPushedCount != null && gitMetrics!.commitsPushedCount > 0;
                final hasPRStats =
                    gitMetrics?.pullRequestsCreatedCount != null && gitMetrics!.pullRequestsCreatedCount > 0;
                final hasPipelinesStats = pipelinesMetrics?.total != null && pipelinesMetrics!.total > 0;

                if (!hasWorkStats && !hasGitStats && !hasPRStats && !hasPipelinesStats) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader.withIcon(
                      text: 'Stats (last 7 days)',
                      icon: Icons.query_stats,
                    ),
                    Wrap(
                      children: [
                        if (hasWorkStats) ...[
                          SizedBox(
                            width: double.maxFinite,
                            child: Text('Work items'),
                          ),
                          _StatsChip(
                            name: 'Created',
                            value: '${workMetrics.workItemsCreated}',
                          ),
                          _StatsChip(
                            name: 'Closed',
                            value: '${workMetrics.workItemsCompleted}',
                          ),
                        ],
                        if (hasGitStats) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Text('Commits'),
                            ),
                          ),
                          _StatsChip(
                            name: 'Pushed',
                            value: '${gitMetrics.commitsPushedCount}',
                          ),
                          _StatsChip(
                            name: 'Authors',
                            value: '${gitMetrics.authorsCount}',
                          ),
                        ],
                        if (hasPRStats) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Text('Pull requests'),
                            ),
                          ),
                          _StatsChip(
                            name: 'Created',
                            value: '${gitMetrics.pullRequestsCreatedCount}',
                          ),
                          _StatsChip(
                            name: 'Closed',
                            value: '${gitMetrics.pullRequestsCompletedCount}',
                          ),
                        ],
                        if (hasPipelinesStats) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Text('Pipelines'),
                            ),
                          ),
                          _StatsChip(
                            name: 'Total',
                            value: '${pipelinesMetrics.total}',
                          ),
                          if (pipelinesMetrics.successful > 0)
                            _StatsChip(
                              name: 'Successful',
                              value: '${pipelinesMetrics.successful}',
                            ),
                          if (pipelinesMetrics.partiallySuccessful > 0)
                            _StatsChip(
                              name: 'Partially successful',
                              value: '${pipelinesMetrics.partiallySuccessful}',
                            ),
                          if (pipelinesMetrics.failed > 0)
                            _StatsChip(
                              name: 'Failed',
                              value: '${pipelinesMetrics.failed}',
                            ),
                          if (pipelinesMetrics.canceled > 0)
                            _StatsChip(
                              name: 'Canceled',
                              value: '${pipelinesMetrics.canceled}',
                            ),
                          _StatsChip(
                            name: 'Success ratio',
                            value: pipeSuccessStr,
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
            if (ctrl.repos.isNotEmpty) ...[
              SectionHeader.withIcon(
                text: 'Repositories',
                icon: DevOpsIcons.list,
              ),
              ...ctrl.repos.map(
                (r) => NavigationButton(
                  onTap: () => ctrl.goToRepoDetail(r),
                  margin: r == ctrl.repos.first ? EdgeInsets.zero : const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(r.name!)),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
