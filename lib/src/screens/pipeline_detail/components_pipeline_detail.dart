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
