part of pipeline_detail;

class _PipelineDetailScreen extends StatelessWidget {
  const _PipelineDetailScreen(this.ctrl, this.parameters);

  final _PipelineDetailController ctrl;
  final _PipelineDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ctrl.visibilityKey,
      onVisibilityChanged: ctrl.visibilityChanged,
      child: AppPage<PipelineWithTimeline?>(
        init: ctrl.init,
        dispose: ctrl.dispose,
        title: 'Pipeline detail',
        notifier: ctrl.buildDetail,
        actions: [
          ListenableBuilder(
            listenable: ctrl.buildDetail,
            builder: (_, __) => ctrl.buildDetail.value?.data?.pipeline == null
                ? const SizedBox()
                : DevOpsPopupMenu(
                    tooltip: 'Pipeline actions',
                    items: () => [
                      PopupItem(
                        onTap: ctrl.goToPreviousRuns,
                        text: 'Previous runs',
                        icon: DevOpsIcons.pipeline,
                      ),
                      PopupItem(
                        onTap: ctrl.getActionFromStatus,
                        text: ctrl.getActionTextFromStatus(),
                        icon: ctrl.getActionIconFromStatus(),
                      ),
                      if (ctrl.hasApprovals)
                        PopupItem(
                          onTap: ctrl.viewAllApprovals,
                          text: 'View approvals',
                          icon: DevOpsIcons.task,
                        ),
                      PopupItem(
                        onTap: ctrl.shareBuild,
                        text: 'Share',
                        icon: DevOpsIcons.share,
                      ),
                    ],
                  ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
        builder: (pipeWithTimeline) {
          final pipeline = pipeWithTimeline!.pipeline;
          return DefaultTextStyle(
            style: context.textTheme.titleSmall!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Triggered by',
                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                ),
                Row(
                  children: [
                    SelectableText(pipeline.requestedFor!.displayName!),
                    if (pipeline.requestedFor?.imageUrl != null && ctrl.api.organization.isNotEmpty) ...[
                      const SizedBox(
                        width: 10,
                      ),
                      MemberAvatar(
                        userDescriptor: pipeline.requestedFor!.descriptor,
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
                    if (pipeline.status == PipelineStatus.inProgress && ctrl.pendingApprovals.isNotEmpty)
                      Icon(
                        Icons.warning,
                        color: Colors.yellow,
                      )
                    else
                      pipeline.status == PipelineStatus.completed ? pipeline.result.icon : pipeline.status.icon,
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (ctrl.hasPendingApprovals)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: Colors.yellow),
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(child: Text(ctrl.getPendingApprovalText())),
                        NavigationButton(onTap: ctrl.viewPendingApprovals, child: Text('View')),
                      ],
                    ),
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
                  repositoryName: pipeline.repository?.name,
                ),
                const SizedBox(
                  height: 20,
                ),
                if (pipeline.triggerInfo?.ciMessage != null) ...[
                  Text(
                    'Commit message',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  SelectableText(
                    pipeline.triggerInfo!.ciMessage ?? '',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'CommitId',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  InkWell(
                    onTap: pipeline.repository?.name == null ? null : ctrl.goToCommitDetail,
                    child: Text(
                      pipeline.triggerInfo!.ciSourceSha!,
                      style: context.textTheme.titleSmall!.copyWith(
                        decoration: pipeline.repository?.name == null ? null : TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
                TextTitleDescription(
                  title: 'Branch:',
                  description: pipeline.sourceBranchShort ?? '',
                ),
                const Divider(
                  height: 40,
                ),
                Row(
                  children: [
                    TextTitleDescription(title: 'Id:', description: pipeline.id!.toString()),
                    const SizedBox(
                      width: 20,
                    ),
                    TextTitleDescription(title: 'Number:', description: pipeline.buildNumber!),
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
                if (pipeline.finishTime != null && pipeline.startTime != null)
                  TextTitleDescription(
                    title: 'Finished at: ',
                    description: '${pipeline.finishTime!.toSimpleDate()} (run for ${ctrl.getRunTime().toMinutes})',
                  ),
                const SizedBox(
                  height: 40,
                ),
                ValueListenableBuilder<List<_Stage>?>(
                  valueListenable: ctrl.pipeStages,
                  builder: (_, records, __) => records == null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Center(child: const CircularProgressIndicator()),
                        )
                      : records.isEmpty
                          ? const SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Timeline:',
                                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ...records.map(
                                  (stage) => Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (stage.stage.name != '__default') _StageRow(stage: stage.stage),
                                      if (stage.phases.isNotEmpty && stage.phases.expand((phase) => phase.jobs).isEmpty)
                                        ...stage.phases.where((p) => p.phase.result == TaskResult.failed).map(
                                              (phase) => Padding(
                                                padding: const EdgeInsets.only(left: 10, top: 5),
                                                child: _PhaseRow(phase: phase.phase),
                                              ),
                                            )
                                      else
                                        ...stage.phases.expand((phase) => phase.jobs).map(
                                              (job) => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10, top: 5),
                                                    child: _JobRow(job: job.job),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  ...job.tasks.map(
                                                    (task) => InkWell(
                                                      onTap: () => ctrl.seeLogs(task),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(bottom: 5, left: 20),
                                                        child: _TaskRow(task: task),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
