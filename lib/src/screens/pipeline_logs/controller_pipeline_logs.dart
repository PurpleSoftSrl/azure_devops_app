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

  // Matches ANSI SGR (color/style) escape sequences, e.g. ESC[31m, ESC[1;31m, ESC[0m.
  static final _ansiSgrRegex = RegExp(r'\x1B\[([0-9;]*)m');

  // Matches any other (non-SGR) ANSI escape sequence, e.g. cursor moves or ESC[0K.
  static final _ansiOtherRegex = RegExp(r'\x1B\[[0-9;]*[A-HJKSTfhlmnsu]');

  /// Maps a foreground SGR color code to a Flutter color legible on a dark background.
  /// Returns `null` for unknown codes or the default-text code (37) so the line falls
  /// back to its default color.
  Color? _ansiColor(String code) {
    switch (code) {
      case '30':
        return Colors.grey;
      case '31':
        return Colors.red;
      case '32':
        return Colors.green;
      case '33':
        return Colors.amber;
      case '34':
        return Colors.blue;
      case '35':
        return Colors.purpleAccent;
      case '36':
        return Colors.cyan;
      case '37':
        return null;
      case '90':
        return Colors.grey.shade400;
      case '91':
        return Colors.redAccent;
      case '92':
        return Colors.greenAccent;
      case '93':
        return Colors.amberAccent;
      case '94':
        return Colors.blueAccent;
      case '95':
        return Colors.purpleAccent.shade100;
      case '96':
        return Colors.cyanAccent;
      case '97':
        return Colors.white;
      default:
        return null;
    }
  }

  /// Converts a (date-trimmed) log line into colored/bold [InlineSpan]s by parsing
  /// the ANSI SGR escape sequences emitted by CLI tools (e.g. Terraform). The line's
  /// Azure `##[...]` color (see [logColor]) is used as the default color so tagged
  /// lines stay colored. Stray non-SGR escape sequences are stripped.
  List<InlineSpan> parseLogLine(String line, TextStyle baseStyle) {
    final defaultColor = logColor(line);
    final clean = line.replaceAll('##[section]', '');

    final spans = <InlineSpan>[];
    Color? color = defaultColor;
    var bold = false;
    var last = 0;

    void emit(String text) {
      if (text.isEmpty) return;
      final t = text.replaceAll(_ansiOtherRegex, '');
      if (t.isEmpty) return;
      spans.add(
        TextSpan(
          text: t,
          style: baseStyle.copyWith(color: color, fontWeight: bold ? FontWeight.bold : null),
        ),
      );
    }

    for (final m in _ansiSgrRegex.allMatches(clean)) {
      emit(clean.substring(last, m.start));
      last = m.end;

      final group = m.group(1) ?? '';
      final codes = group.isEmpty ? ['0'] : group.split(';');
      for (final code in codes) {
        switch (code) {
          case '0':
            color = defaultColor;
            bold = false;
          case '1':
            bold = true;
          case '22':
            bold = false;
          case '39':
            color = defaultColor;
          default:
            final c = _ansiColor(code);
            if (c != null) color = c;
        }
      }
    }
    emit(clean.substring(last));

    // Preserve the height of blank lines (or lines that were only escape codes).
    if (spans.isEmpty) spans.add(TextSpan(text: '', style: baseStyle));

    return spans;
  }

  String _getBuildWebUrl() {
    return '${api.basePath}/${args.project}/_build/results?buildId=${args.pipelineId}&view=logs&j=${args.parentTaskId}&t=${args.taskId}';
  }

  void shareLogs() {
    shareUrl(_getBuildWebUrl());
  }
}
