part of pipeline_logs;

class _PipelineLogsController with ShareMixin {
  _PipelineLogsController._(this.api, this.args);

  final AzureApiService api;
  final PipelineLogsArgs args;

  final logs = ValueNotifier<ApiResponse<String?>?>(null);

  Future<void> init() async {
    final res = await api.getPipelineTaskLogs(
      projectName: args.project,
      pipelineId: args.pipelineId,
      logId: args.logId,
    );

    logs.value = res;
  }

  String trimDate(String line) {
    return line.length >= 28 && DateTime.tryParse(line.substring(0, 28)) != null
        ? line.replaceRange(0, 11, '').replaceRange(8, 17, '')
        : line;
  }

  Color? logColor(String l) {
    if (!l.contains('##')) return null;

    if (l.contains('##[warning]')) return Colors.orange;
    if (l.contains('##[error]')) return Colors.red;
    if (l.contains('##[section]')) return Colors.green;
    if (l.contains('##[debug]')) return Colors.purple;
    if (l.contains('##[command]')) return Colors.lightBlue;

    return null;
  }

  String _getBuildWebUrl() {
    return '${api.basePath}/${args.project}/_build/results?buildId=${args.pipelineId}&view=logs&j=${args.parentTaskId}&t=${args.taskId}';
  }

  void shareLogs() {
    shareUrl(_getBuildWebUrl());
  }
}
