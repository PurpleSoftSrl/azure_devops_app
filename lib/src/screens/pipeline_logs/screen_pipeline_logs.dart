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
      builder: (logs) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(logs ?? ''),
      ),
    );
  }
}
