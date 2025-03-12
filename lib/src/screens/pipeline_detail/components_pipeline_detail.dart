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
    required this.isBlockedApprover,
    required this.onApprove,
    required this.onDefer,
    required this.onReject,
  });

  final List<Approval> approvals;
  final bool Function(Approval) canApprove;
  final bool Function(Approval) isBlockedApprover;
  final void Function(Approval) onApprove;
  final void Function(Approval) onDefer;
  final void Function(Approval) onReject;

  @override
  Widget build(BuildContext context) {
    final sortedApprovals = approvals.sorted(
      (a, b) => max(a.getLastStepTimestamp(), b.getLastStepTimestamp()),
    );

    return ListView(
      children: [
        ...sortedApprovals.map(
          (approval) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Requirement'),
              const SizedBox(height: 5),
              Text(
                approval.executionOrderDescription,
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              ...approval.steps.sortedBy((s) => s.lastModifiedOn ?? DateTime.now()).map(
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
                              Text(
                                step.assignedApprover.displayName,
                              ),
                              Text(
                                step.statusDescription,
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (canApprove(approval))
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: DevOpsPopupMenu(
                                tooltip: '$approval actions',
                                offset: const Offset(0, 20),
                                constraints: BoxConstraints(minWidth: 150),
                                items: () => [
                                  PopupItem(
                                    onTap: () => onApprove(approval),
                                    text: 'Approve',
                                    icon: DevOpsIcons.success,
                                  ),
                                  PopupItem(
                                    onTap: () => onDefer(approval),
                                    text: 'Defer',
                                    icon: DevOpsIcons.queued,
                                  ),
                                  PopupItem(
                                    onTap: () => onReject(approval),
                                    text: 'Reject',
                                    icon: DevOpsIcons.failed,
                                  ),
                                ],
                              ),
                            ),
                          step.statusIcon,
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              if (approval.instructions.isNotEmpty) ...[
                Text('Instructions'),
                const SizedBox(height: 5),
                Text(
                  approval.instructions,
                  style: context.textTheme.bodySmall,
                ),
              ],
              if (isBlockedApprover(approval)) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: Colors.orange, width: .5),
                  ),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.orange,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'Configurations on this approval prevent you from approving your own run.',
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (approval != sortedApprovals.last)
                const Divider(
                  height: 60,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeferApprovalBottomSheet extends StatefulWidget {
  const _DeferApprovalBottomSheet();

  @override
  State<_DeferApprovalBottomSheet> createState() => _DeferApprovalBottomSheetState();
}

class _DeferApprovalBottomSheetState extends State<_DeferApprovalBottomSheet> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  var _date = DateTime.now();
  var _time = TimeOfDay.now();

  final _formKey = GlobalKey<FormState>();

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: AppRouter.rootNavigator!.context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (date == null) return;

    _date = date;
    _dateController.text = date.toDate();
  }

  Future<void> _showTimePicker() async {
    final time = await showTimePicker(
      context: AppRouter.rootNavigator!.context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    if (!mounted) return;

    _time = time;
    _timeController.text = time.format(context);
  }

  final _timeZone = DateTime.now().timeZoneName;
  String get _timeZoneOffset {
    final now = DateTime.now();

    final hours = now.timeZoneOffset.inHours;
    final minutes = now.timeZoneOffset.inMinutes.remainder(60);
    final sign = hours.isNegative ? '-' : '+';

    return '$sign${hours.abs()}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DevOpsFormField(
            label: 'Date',
            controller: _dateController,
            onChanged: (_) {},
            readOnly: true,
            onTap: _showDatePicker,
          ),
          const SizedBox(
            height: 20,
          ),
          DevOpsFormField(
            label: 'Time',
            controller: _timeController,
            onChanged: (_) {},
            readOnly: true,
            onTap: _showTimePicker,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Time zone: (UTC$_timeZoneOffset) $_timeZone',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          LoadingButton(
            onPressed: () {
              final isValid = _formKey.currentState!.validate();
              if (!isValid) return;

              final dateTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

              AppRouter.popRoute(result: dateTime);
            },
            text: 'Defer',
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
