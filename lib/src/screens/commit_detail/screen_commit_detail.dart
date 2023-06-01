part of commit_detail;

class _CommitDetailScreen extends StatelessWidget {
  const _CommitDetailScreen(this.ctrl, this.parameters);

  final _CommitDetailController ctrl;
  final _CommitDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<CommitChanges?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Commit detail',
      actions: [
        IconButton(
          onPressed: ctrl.shareDiff,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      notifier: ctrl.commitChanges,
      onEmpty: (_) => Text('No commit found'),
      padding: const EdgeInsets.only(left: 16),
      builder: (detail) => DefaultTextStyle(
        style: context.textTheme.titleSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ctrl.commitDetail!.author != null)
                    Row(
                      children: [
                        Text(
                          'Author: ',
                          style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                        ),
                        Text(
                          ctrl.commitDetail!.author!.name!,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ctrl.apiService.organization.isNotEmpty && ctrl.commitDetail!.author!.imageUrl != null) ...[
                          const SizedBox(
                            width: 20,
                          ),
                          MemberAvatar(
                            // shows placeholder image for committers not inside the organization
                            imageUrl: ctrl.commitDetail!.author!.imageUrl!.startsWith(ctrl.apiService.basePath)
                                ? null
                                : ctrl.commitDetail!.author!.imageUrl,
                            userDescriptor: ctrl.commitDetail!.author!.imageUrl!.split('/').last,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                        const Spacer(),
                        Text(ctrl.commitDetail!.author!.date!.minutesAgo),
                      ],
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  ProjectChip(
                    onTap: ctrl.goToProject,
                    projectName: ctrl.args.project,
                  ),
                  RepositoryChip(
                    onTap: ctrl.goToRepo,
                    repositoryName: ctrl.args.repository,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Message: ',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  Text(
                    ctrl.commitDetail!.comment!,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'CommitId: ',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  SelectableText(ctrl.args.commitId),
                  const SizedBox(
                    height: 20,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Committed at: ',
                          style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                        ),
                        TextSpan(
                          text: ctrl.commitDetail!.author!.date!.toSimpleDate(),
                          style: context.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 40,
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: context.textTheme.titleLarge,
                    ),
                    if (detail!.changeCounts?.edit != null)
                      Text('${detail.changeCounts!.edit} line${detail.changeCounts!.edit == 1 ? '' : 's'} edited'),
                    if (detail.changeCounts?.add != null)
                      Text('${detail.changeCounts!.add} line${detail.changeCounts!.add == 1 ? '' : 's'} added'),
                    if (detail.changeCounts?.delete != null)
                      Text('${detail.changeCounts!.delete} line${detail.changeCounts!.delete == 1 ? '' : 's'} deleted'),
                    const SizedBox(
                      height: 20,
                    ),
                    if (ctrl.addedFilesCount > 0) ...[
                      Text(
                        '${ctrl.addedFilesCount} added file${ctrl.addedFilesCount == 1 ? '' : 's'}',
                        style: context.textTheme.titleLarge,
                      ),
                      ...ctrl.addedFiles.map(
                        (c2) => InkWell(
                          onTap: () => ctrl.goToFileDiff(filePath: c2.item!.path!, isAdded: true),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              c2!.item!.path!.startsWith('/') ? c2.item!.path!.substring(1) : c2.item!.path!,
                              style: context.textTheme.titleSmall!.copyWith(
                                color: context.colorScheme.onSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (ctrl.editedFilesCount > 0) ...[
                      Text(
                        '${ctrl.editedFilesCount} edited file${ctrl.editedFilesCount == 1 ? '' : 's'}',
                        style: context.textTheme.titleLarge,
                      ),
                      ...ctrl.editedFiles.map(
                        (c2) => InkWell(
                          onTap: () => ctrl.goToFileDiff(filePath: c2.item!.path!),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              c2!.item!.path!.startsWith('/') ? c2.item!.path!.substring(1) : c2.item!.path!,
                              maxLines: 1,
                              softWrap: false,
                              style: context.textTheme.titleSmall!.copyWith(
                                color: context.colorScheme.onSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (ctrl.deletedFilesCount > 0) ...[
                      Text(
                        '${ctrl.deletedFilesCount} deleted file${ctrl.deletedFilesCount == 1 ? '' : 's'}',
                        style: context.textTheme.titleLarge,
                      ),
                      ...ctrl.deletedFiles.map(
                        (c2) => InkWell(
                          onTap: () => ctrl.goToFileDiff(filePath: c2.item!.path!, isDeleted: true),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              c2!.item!.path!.startsWith('/') ? c2.item!.path!.substring(1) : c2.item!.path!,
                              style: context.textTheme.titleSmall!.copyWith(
                                color: context.colorScheme.onSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
