import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';

extension PullRequestExt on PullRequest {
  String get sourceBranch => sourceRefName.replaceFirst('refs/heads/', '');
  String get targetBranch => targetRefName.replaceFirst('refs/heads/', '');
}

extension PullRequestStringExt on String {
  String get voteDescription {
    if (!contains('voted')) return this;

    final vote = split(' ').lastOrNull;
    if (vote == null) return this;

    final parsedVote = int.tryParse(vote);
    if (parsedVote == null) return this;

    switch (parsedVote) {
      case 10:
        return 'approved the pull request';
      case 5:
        return 'approved the pull request with suggestions';
      case -10:
        return 'rejected the pull request';
      case -5:
        return 'is waiting for the author';
      case 0:
        return 'reset their vote';
      default:
        return this;
    }
  }

  Icon? get voteIcon {
    if (!contains('voted')) return null;

    final vote = split(' ').lastOrNull;
    if (vote == null) return null;

    final parsedVote = int.tryParse(vote);
    if (parsedVote == null) return null;

    switch (parsedVote) {
      case 10:
      case 5:
        return Icon(DevOpsIcons.success, color: Colors.green);
      case -10:
        return Icon(DevOpsIcons.failed, color: Colors.red);
      case -5:
        return Icon(DevOpsIcons.queuedsolid, color: Colors.orange);
      default:
        return null;
    }
  }

  String get statusUpdateDescription {
    final status = split(' ').lastOrNull;
    if (status == null) return this;

    final parsedStatus = PullRequestStatus.fromString(status.toLowerCase());

    switch (parsedStatus) {
      case PullRequestStatus.abandoned:
        return 'abandoned';
      case PullRequestStatus.active:
        return 'reactivated';
      case PullRequestStatus.completed:
        return 'completed';
      case PullRequestStatus.notSet:
      case PullRequestStatus.all:
        return '';
    }
  }
}

extension PullRequestStatusExt on PullRequestStatus {
  String toVerb() {
    switch (this) {
      case PullRequestStatus.abandoned:
        return 'abandon';
      case PullRequestStatus.active:
        return 'reactivate';
      case PullRequestStatus.completed:
        return 'complete';
      case PullRequestStatus.notSet:
      case PullRequestStatus.all:
        return '';
    }
  }
}
