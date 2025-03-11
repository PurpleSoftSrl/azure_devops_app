part of pipeline_detail;

class _StageRow extends StatelessWidget {
  const _StageRow({required this.stage});

  final Record stage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (stage.state == TaskStatus.inProgress)
          InProgressPipelineIcon(
            child: stage.state.icon,
          )
        else
          stage.state == TaskStatus.completed && stage.result != null ? stage.result!.icon : stage.state.icon,
        const SizedBox(
          width: 10,
        ),
        Expanded(child: Text('${stage.name} (${stage.type})')),
        const SizedBox(
          width: 8,
        ),
        Text(stage.getRunTime()),
      ],
    );
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({required this.phase});

  final Record phase;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (phase.state == TaskStatus.inProgress)
          InProgressPipelineIcon(
            child: phase.state.icon,
          )
        else
          phase.state == TaskStatus.completed && phase.result != null ? phase.result!.icon : phase.state.icon,
        const SizedBox(
          width: 10,
        ),
        Expanded(child: Text('${phase.name} (Job)')),
        const SizedBox(
          width: 8,
        ),
        Text(phase.getRunTime()),
      ],
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job});

  final Record job;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (job.state == TaskStatus.inProgress)
          InProgressPipelineIcon(
            child: job.state.icon,
          )
        else
          job.state == TaskStatus.completed && job.result != null ? job.result!.icon : job.state.icon,
        const SizedBox(
          width: 10,
        ),
        Expanded(child: Text('${job.name} (${job.type})')),
        const SizedBox(
          width: 8,
        ),
        Text(job.getRunTime()),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final Record task;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (task.state == TaskStatus.inProgress)
          InProgressPipelineIcon(
            child: task.state.icon,
          )
        else
          task.state == TaskStatus.completed && task.result != null ? task.result!.icon : task.state.icon,
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            task.name,
            style: context.textTheme.titleSmall!.copyWith(
              decoration: TextDecoration.underline,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(task.getRunTime()),
      ],
    );
  }
}

class _PendingApprovalsBottomSheet extends StatelessWidget {
  const _PendingApprovalsBottomSheet({
    required this.approvals,
    required this.canApprove,
    required this.onApprove,
    required this.onReject,
  });

  final List<Approval> approvals;
  final bool Function(Approval) canApprove;
  final void Function(Approval) onApprove;
  final void Function(Approval) onReject;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...approvals.map(
          (approval) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Requirement'),
              const SizedBox(height: 5),
              Text(approval.executionOrderDescription, style: context.textTheme.bodySmall),
              const SizedBox(height: 10),
              ...approval.steps.map(
                (step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      MemberAvatar(
                        userDescriptor: step.assignedApprover.descriptor,
                        radius: 20,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.assignedApprover.displayName),
                          if (['approved', 'rejected'].contains(step.status))
                            Text(
                              '${step.status.titleCase} ${step.lastModifiedOn?.minutesAgo} ${step.lastModifiedOn?.minutesAgo == 'now' ? '' : 'ago'}',
                              style: context.textTheme.bodySmall,
                            ),
                        ],
                      ),
                      const Spacer(),
                      if (step.status == 'approved')
                        Icon(
                          DevOpsIcons.success,
                          color: Colors.green,
                        )
                      else if (step.status == 'rejected')
                        Icon(
                          DevOpsIcons.failed,
                          color: context.colorScheme.error,
                        )
                      else if (step.status == 'pending')
                        Icon(
                          DevOpsIcons.queued,
                          color: Colors.blue,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (approval.instructions.isNotEmpty) ...[
                Text('Instructions'),
                const SizedBox(height: 5),
                Text(approval.instructions, style: context.textTheme.bodySmall),
                const SizedBox(height: 40),
              ],
              if (canApprove(approval))
                Row(
                  children: [
                    Expanded(
                      child: LoadingButton(
                        onPressed: () => onApprove(approval),
                        text: 'Approve',
                        margin: const EdgeInsets.only(right: 10),
                      ),
                    ),
                    Expanded(
                      child: LoadingButton(
                        onPressed: () => onReject(approval),
                        text: 'Reject',
                        margin: const EdgeInsets.only(left: 10),
                        backgroundColor: context.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }
}

extension on Approval {
  String get executionOrderDescription =>
      'All approvers must approve${executionOrder == 'inSequence' ? ' in sequence' : ''}';
}
