part of commit_detail;

class _CommitDetailScreen extends StatelessWidget {
  const _CommitDetailScreen(this.ctrl, this.parameters);

  final _CommitDetailController ctrl;
  final _CommitDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<CommitWithChanges?>(
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
      padding: const EdgeInsets.only(left: 16),
      builder: (detail) {
        final author = detail!.commit.author;
        return DefaultTextStyle(
          style: context.textTheme.titleSmall!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (author != null)
                      Row(
                        children: [
                          Text(
                            'Author: ',
                            style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                          ),
                          Text(
                            author.name!,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (ctrl.apiService.organization.isNotEmpty && author.imageUrl != null) ...[
                            const SizedBox(
                              width: 20,
                            ),
                            MemberAvatar(
                              // shows placeholder image for committers not inside the organization
                              imageUrl: author.imageUrl!.startsWith(ctrl.apiService.basePath) ? null : author.imageUrl,
                              userDescriptor: author.imageUrl!.split('/').last,
                              radius: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                          const Spacer(),
                          Text(author.date!.minutesAgo),
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
                      detail.commit.comment!,
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
                            text: author?.date?.toSimpleDate() ?? '-',
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
                      if (detail.changes?.changeCounts != null)
                        Text(
                          'Details',
                          style: context.textTheme.titleLarge,
                        ),
                      if (ctrl.editedLines > 0)
                        Text('${ctrl.editedLines} line${ctrl.editedLines == 1 ? '' : 's'} edited'),
                      if (ctrl.addedLines > 0) Text('${ctrl.addedLines} line${ctrl.addedLines == 1 ? '' : 's'} added'),
                      if (ctrl.deletedLines > 0)
                        Text('${ctrl.deletedLines} line${ctrl.deletedLines == 1 ? '' : 's'} deleted'),
                      const SizedBox(
                        height: 20,
                      ),
                      if (ctrl.addedFilesCount > 0) ...[
                        Text(
                          '${ctrl.addedFilesCount} added file${ctrl.addedFilesCount == 1 ? '' : 's'}',
                          style: context.textTheme.titleLarge,
                        ),
                        _GroupedFiles(
                          groupedFiles: ctrl.groupedAddedFiles,
                          onTap: (path) => ctrl.goToFileDiff(filePath: path, isAdded: true),
                        ),
                      ],
                      if (ctrl.editedFilesCount > 0) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          '${ctrl.editedFilesCount} edited file${ctrl.editedFilesCount == 1 ? '' : 's'}',
                          style: context.textTheme.titleLarge,
                        ),
                        _GroupedFiles(
                          groupedFiles: ctrl.groupedEditedFiles,
                          onTap: (path) => ctrl.goToFileDiff(filePath: path),
                        ),
                      ],
                      if (ctrl.deletedFilesCount > 0) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          '${ctrl.deletedFilesCount} deleted file${ctrl.deletedFilesCount == 1 ? '' : 's'}',
                          style: context.textTheme.titleLarge,
                        ),
                        _GroupedFiles(
                          groupedFiles: ctrl.groupedDeletedFiles,
                          onTap: (path) => ctrl.goToFileDiff(filePath: path, isDeleted: true),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
