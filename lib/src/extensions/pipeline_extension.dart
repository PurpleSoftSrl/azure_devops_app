import 'package:azure_devops/src/models/pipeline.dart';

extension BuildExt on Pipeline {
  String? get sourceBranchShort => sourceBranch?.replaceFirst('refs/heads/', '');
}
