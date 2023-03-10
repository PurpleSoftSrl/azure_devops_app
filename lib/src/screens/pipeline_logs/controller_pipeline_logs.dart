part of pipeline_logs;

class _PipelineLogsController {
  factory _PipelineLogsController({required AzureApiService apiService, required PipelineLogsArgs args}) {
    return instance ??= _PipelineLogsController._(apiService, args);
  }

  _PipelineLogsController._(this.apiService, this.args);

  static _PipelineLogsController? instance;

  final AzureApiService apiService;
  final PipelineLogsArgs args;

  final logs = ValueNotifier<ApiResponse<String?>?>(null);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final res = await apiService.getPipelineTaskLogs(
      projectName: args.pipeline.project!.name!,
      pipelineId: args.pipeline.id!,
      logId: args.task.log!.id,
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
}
