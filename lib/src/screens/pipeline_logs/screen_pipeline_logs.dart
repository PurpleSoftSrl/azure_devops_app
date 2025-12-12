part of pipeline_logs;

class _PipelineLogsScreen extends StatelessWidget {
  const _PipelineLogsScreen(this.ctrl, this.parameters);

  final _PipelineLogsController ctrl;
  final _PipelineLogsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<String?>(
      init: ctrl.init,
      title: 'Pipeline logs',
      notifier: ctrl.logs,
      padding: const EdgeInsets.only(left: 8),
      showScrollbar: true,
      actions: [IconButton(onPressed: ctrl.shareLogs, icon: Icon(DevOpsIcons.share))],
      builder: (logs) => switch (logs) {
        '' => const Padding(
          padding: EdgeInsets.only(top: 150),
          child: Text('No logs found', textAlign: TextAlign.center),
        ),
        _ => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (logs!.length >= 28) ...[
                Text(
                  DateTime.tryParse(logs.trim().substring(0, 28))?.toDate() ?? '',
                  style: context.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 5),
              ],
              ...logs
                  .split('\n')
                  .map(ctrl.trimDate)
                  .map(
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
      },
    );
  }
}
