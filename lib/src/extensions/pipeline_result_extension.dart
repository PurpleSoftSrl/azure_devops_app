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
        break;
      case PipelineStatus.cancelling:
        icon = Icon(
          DevOpsIcons.cancelled,
          color: Colors.blue,
        );
        break;
      case PipelineStatus.inProgress:
        icon = Icon(
          DevOpsIcons.running,
          color: Colors.blue,
        );
        break;
      case PipelineStatus.completed:
        icon = Icon(
          DevOpsIcons.success,
          color: Colors.blue,
        );
        break;
      case PipelineStatus.postponed:
        icon = Icon(
          Icons.watch_later,
          color: Colors.blue,
        );
        break;
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
        break;
      case PipelineResult.failed:
        icon = Icon(
          DevOpsIcons.failed,
          color: Colors.red,
        );
        break;
      case PipelineResult.none:
        icon = Icon(
          Icons.question_mark,
          color: Colors.grey,
        );
        break;
      case PipelineResult.partiallySucceeded:
        icon = Icon(
          Icons.checklist,
          color: Colors.cyanAccent,
        );
        break;
      case PipelineResult.succeeded:
        icon = Icon(
          DevOpsIcons.success,
          color: Colors.green,
        );
        break;
      default:
        icon = Icon(
          Icons.question_mark,
          color: Colors.transparent,
        );
    }

    return icon;
  }
}
