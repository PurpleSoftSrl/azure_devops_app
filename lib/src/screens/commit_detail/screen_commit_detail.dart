part of commit_detail;

class _CommitDetailScreen extends StatelessWidget {
  const _CommitDetailScreen(this.ctrl, this.parameters);

  final _CommitDetailController ctrl;
  final _CommitDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<CommitDetail?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Commit detail',
      actions: [
        IconButton(
          onPressed: ctrl.shareDiff,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      notifier: ctrl.commitDetail,
      onEmpty: (_) => Text('No commit found'),
      builder: (detail) => DefaultTextStyle(
        style: context.textTheme.titleSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Author: ',
                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                ),
                Text(
                  ctrl.commit.author!.name!,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ctrl.apiService.organization.isNotEmpty && ctrl.author?.descriptor != null) ...[
                  const SizedBox(
                    width: 20,
                  ),
                  MemberAvatar(
                    userDescriptor: ctrl.author!.descriptor!,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                const Spacer(),
                Text(ctrl.commit.author!.date!.minutesAgo),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ProjectChip(
              onTap: ctrl.goToProject,
              projectName: ctrl.commit.projectName,
            ),
            RepositoryChip(
              onTap: ctrl.goToRepo,
              repositoryName: ctrl.commit.repositoryName,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Message: ',
              style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
            ),
            Text(
              ctrl.commit.comment!,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'CommitId: ',
              style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
            ),
            SelectableText(ctrl.commit.commitId!),
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
                    text: ctrl.commit.author!.date!.toSimpleDate(),
                    style: context.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            const Divider(
              height: 40,
            ),
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
                '${ctrl.addedFilesCount} added file${ctrl.addedFilesCount == 1 ? '' : 's'}:',
                style: context.textTheme.titleLarge,
              ),
              ...ctrl.addedFiles.map(
                (c2) => InkWell(
                  onTap: () => ctrl.goToFileDiff(filePath: c2.item!.path!, isAdded: true),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      c2!.item!.path!.startsWith('/') ? c2.item!.path!.substring(1) : c2.item!.path!,
                      style: context.textTheme.titleSmall!
                          .copyWith(color: context.colorScheme.onSecondary, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),
            ],
            if (ctrl.editedFilesCount > 0) ...[
              Text(
                '${ctrl.editedFilesCount} edited file${ctrl.editedFilesCount == 1 ? '' : 's'}:',
                style: context.textTheme.titleLarge,
              ),
              ...ctrl.editedFiles.map(
                (c2) => InkWell(
                  onTap: () => ctrl.goToFileDiff(filePath: c2.item!.path!, isAdded: false),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      c2!.item!.path!.startsWith('/') ? c2.item!.path!.substring(1) : c2.item!.path!,
                      style: context.textTheme.titleSmall!
                          .copyWith(color: context.colorScheme.onSecondary, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),
            ],
            if (ctrl.deletedFilesCount > 0) ...[
              Text(
                '${ctrl.deletedFilesCount} deleted file${ctrl.deletedFilesCount == 1 ? '' : 's'}:',
                style: context.textTheme.titleLarge,
              ),
              ...ctrl.deletedFiles.map(
                (c2) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    c2!.item!.path!.startsWith('/') ? c2.item!.path!.substring(1) : c2.item!.path!,
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
