import 'package:azure_devops/src/models/areas_and_iterations.dart';

extension AreaOrIterationExt on AreaOrIteration {
  String get escapedAreaPath => _getReplaced('Area');

  String get escapedIterationPath => _getReplaced('Iteration');

  String _getReplaced(String str) {
    final startsWithBackslash = path.startsWith(r'\');
    final res = startsWithBackslash ? path.substring(1) : path;
    return res.endsWith('\\$str') ? res.replaceFirst('\\$str', '') : res.replaceAll('\\$str\\', r'\');
  }

  String get projectName {
    final startsWithBackslash = path.startsWith(r'\');
    final res = startsWithBackslash ? path.substring(1) : path;
    return res.split(r'\').first;
  }

  bool get isActive {
    final now = DateTime.now();
    return attributes != null && now.isAfter(attributes!.startDate) && now.isBefore(attributes!.finishDate);
  }
}
