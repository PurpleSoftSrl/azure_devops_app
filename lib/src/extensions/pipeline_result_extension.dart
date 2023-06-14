import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';

extension PipelineStatusExt on PipelineStatus? {
  Icon get icon {
    Icon icon;

    switch (this) {
      case PipelineStatus.notStarted:
        icon = Icon(
          DevOpsIcons.queued,
          color: Colors.blue,
        );
      case PipelineStatus.cancelling:
        icon = Icon(
          DevOpsIcons.cancelled,
          color: Colors.blue,
        );
      case PipelineStatus.inProgress:
        icon = Icon(
          DevOpsIcons.running,
          color: Colors.blue,
        );
      case PipelineStatus.completed:
        icon = Icon(
          DevOpsIcons.success,
          color: Colors.blue,
        );
      case PipelineStatus.postponed:
        icon = Icon(
          Icons.watch_later,
          color: Colors.blue,
        );
      default:
        icon = Icon(
          Icons.warning,
          color: Colors.transparent,
        );
    }

    return icon;
  }

  int get order {
    switch (this) {
      case PipelineStatus.inProgress:
        return 1;
      case PipelineStatus.notStarted:
        return 2;
      case PipelineStatus.all:
        return 9;
      case PipelineStatus.cancelling:
        return 9;
      case PipelineStatus.completed:
        return 9;
      case PipelineStatus.none:
        return 9;
      case PipelineStatus.postponed:
        return 9;
      default:
        throw 'Unknown enum value: $this';
    }
  }
}

extension PipelineResultExt on PipelineResult? {
  Icon get icon {
    Icon icon;

    switch (this) {
      case PipelineResult.canceled:
        icon = Icon(
          DevOpsIcons.cancelled,
          color: AppRouter.rootNavigator!.context.colorScheme.onBackground,
        );
      case PipelineResult.failed:
        icon = Icon(
          DevOpsIcons.failed,
          color: Colors.red,
        );
      case PipelineResult.none:
        icon = Icon(
          Icons.question_mark,
          color: Colors.grey,
        );
      case PipelineResult.partiallySucceeded:
        icon = Icon(
          Icons.checklist,
          color: Colors.cyanAccent,
        );
      case PipelineResult.succeeded:
        icon = Icon(
          DevOpsIcons.success,
          color: Colors.green,
        );
      default:
        icon = Icon(
          Icons.question_mark,
          color: Colors.transparent,
        );
    }

    return icon;
  }
}
