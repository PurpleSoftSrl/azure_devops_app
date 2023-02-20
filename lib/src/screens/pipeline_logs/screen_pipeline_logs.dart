part of pipeline_logs;

class _PipelineLogsScreen extends StatelessWidget {
  const _PipelineLogsScreen(this.ctrl, this.parameters);

  final _PipelineLogsController ctrl;
  final _PipelineLogsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<String?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Pipeline logs',
      notifier: ctrl.logs,
      onEmpty: (_) => Text('No logs found'),
      padding: const EdgeInsets.only(left: 8),
      builder: (logs) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateTime.parse(logs!.trim().substring(0, 28)).toDate(),
              style: context.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.normal),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              logs
                  .split('\n')
                  .map(
                    (l) => l.length < 28 ? l : l.replaceRange(0, 11, '').replaceRange(8, 17, ''),
                  )
                  .join('\n'),
              style: context.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
