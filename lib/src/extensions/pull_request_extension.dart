import 'package:azure_devops/src/models/pull_request.dart';

extension PullRequestExt on PullRequest {
  String get sourceBranch => sourceRefName.replaceFirst('refs/heads/', '');
  String get targetBranch => targetRefName.replaceFirst('refs/heads/', '');
}
