part of pipeline_detail;

class _PipelineDetailScreen extends StatelessWidget {
  const _PipelineDetailScreen(this.ctrl, this.parameters);

  final _PipelineDetailController ctrl;
  final _PipelineDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<Pipeline?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Pipeline detail',
      notifier: ctrl.buildDetail,
      onEmpty: (_) => Text('No pipeline found'),
      actions: [
        IconButton(
          onPressed: ctrl.shareBuild,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      builder: (pipeline) => DefaultTextStyle(
        style: context.textTheme.titleSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Triggered by:',
              style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
            ),
            Row(
              children: [
                Text(pipeline!.requestedFor!.displayName!),
                if (pipeline.requestedFor?.imageUrl != null && ctrl.apiService.organization.isNotEmpty) ...[
                  const SizedBox(
                    width: 10,
                  ),
                  MemberAvatar(
                    userDescriptor: pipeline.requestedFor!.descriptor!,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                const Spacer(),
                Text(pipeline.queueTime!.minutesAgo),
                const SizedBox(
                  width: 10,
                ),
                if (pipeline.status == PipelineStatus.inProgress)
                  InProgressPipelineIcon(
                    child: Icon(
                      DevOpsIcons.running2,
                      color: Colors.blue,
                    ),
                  )
                else
                  pipeline.status == PipelineStatus.completed ? pipeline.result.icon : pipeline.status.icon,
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ProjectChip(
              onTap: ctrl.goToProject,
              projectName: pipeline.project!.name!,
            ),
            RepositoryChip(
              onTap: ctrl.goToRepo,
              repositoryName: pipeline.repository!.name!,
            ),
            const SizedBox(
              height: 20,
            ),
            if (pipeline.triggerInfo?.ciMessage != null) ...[
              Text(
                'Commit message: ',
                style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
              ),
              Text(
                pipeline.triggerInfo!.ciMessage ?? '',
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'CommitId: ',
                style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
              ),
              InkWell(
                onTap: ctrl.goToCommitDetail,
                child: Text(
                  pipeline.triggerInfo!.ciSourceSha!,
                  style: context.textTheme.titleSmall!.copyWith(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Branch: ',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  TextSpan(text: pipeline.sourceBranchShort!),
                ],
              ),
            ),
            const Divider(
              height: 40,
            ),
            Row(
              children: [
                TextTitleDescription(title: 'Id: ', description: pipeline.id!.toString()),
                const SizedBox(
                  width: 20,
                ),
                TextTitleDescription(title: 'Number: ', description: pipeline.buildNumber!),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextTitleDescription(title: 'Queued at: ', description: pipeline.queueTime?.toSimpleDate() ?? '-'),
            const SizedBox(
              height: 10,
            ),
            if (pipeline.startTime != null)
              TextTitleDescription(
                title: 'Started at: ',
                description: '${pipeline.startTime!.toSimpleDate()} (queued for ${ctrl.getQueueTime().toMinutes})',
              ),
            const SizedBox(
              height: 10,
            ),
            if (pipeline.finishTime != null)
              TextTitleDescription(
                title: 'Finished at: ',
                description: '${pipeline.finishTime!.toSimpleDate()} (run for ${ctrl.getRunTime().toMinutes})',
              ),
            const SizedBox(
              height: 40,
            ),
            if (pipeline.status != PipelineStatus.cancelling)
              LoadingButton(
                onPressed: ctrl.getActionFromStatus,
                text: ctrl.getActionTextFromStatus(),
              ),
          ],
        ),
      ),
    );
  }
}
