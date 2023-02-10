import 'package:azure_devops/src/models/commit.dart';

extension CommitExt on Commit {
  String get projectName => remoteUrl!.substring(0, remoteUrl!.indexOf('/_git/')).split('/').last;

  String get repositoryName => remoteUrl!.substring(0, remoteUrl!.indexOf('/commit/')).split('/').last;
}
