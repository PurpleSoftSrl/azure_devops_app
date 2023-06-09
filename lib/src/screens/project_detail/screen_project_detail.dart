part of project_detail;

class _ProjectDetailScreen extends StatelessWidget {
  const _ProjectDetailScreen(this.ctrl, this.parameters);

  final _ProjectDetailController ctrl;
  final _ProjectDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return AppPage<Project?>(
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
            const SizedBox(height: 24),
          ],
          if (ctrl.members.isNotEmpty) ...[
            SectionHeader.noMargin(
              text: project.defaultTeam!.name,
              icon: DevOpsIcons.users,
            ),
            Wrap(
              children: ctrl.members
                  .map(
                    (m) => Container(
                      width: parameters.memberAvatarSize + 15,
                      margin: const EdgeInsets.only(right: 12, bottom: 12),
                      child: Column(
                        children: [
                          MemberAvatar(
                            userDescriptor: m.identity!.descriptor!,
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
          if (ctrl.repos.isNotEmpty) ...[
            SectionHeader.withIcon(
              text: 'Repositories',
              icon: DevOpsIcons.list,
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
        ],
      ),
    );
  }
}
