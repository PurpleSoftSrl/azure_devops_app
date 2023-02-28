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
      showScrollbar: true,
      builder: (logs) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateTime.tryParse(logs!.trim().substring(0, 28))?.toDate() ?? '',
              style: context.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.normal),
            ),
            const SizedBox(
              height: 5,
            ),
            ...logs.split('\n').map(ctrl.trimDate).map(
                  (l) => Text(
                    l.replaceAll('##[section]', ''),
                    style: context.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: ctrl.logColor(l),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
