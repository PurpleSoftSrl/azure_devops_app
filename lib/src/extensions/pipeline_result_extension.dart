import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/pipeline_in_progress_animated_icon.dart';
import 'package:flutter/material.dart';

extension PipelineStatusExt on PipelineStatus? {
  Widget get icon {
    switch (this) {
      case PipelineStatus.notStarted:
        return Icon(DevOpsIcons.queued, color: Colors.blue);
      case PipelineStatus.cancelling:
        return Icon(DevOpsIcons.cancelled, color: Colors.blue);
      case PipelineStatus.inProgress:
        return InProgressPipelineIcon(child: Icon(DevOpsIcons.running, color: Colors.blue));
      case PipelineStatus.completed:
        return Icon(DevOpsIcons.success, color: Colors.blue);
      case PipelineStatus.postponed:
        return Icon(DevOpsIcons.queuedsolid, color: Colors.blue);
      default:
        return Icon(Icons.warning, color: Colors.transparent);
    }
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
  Widget get icon {
    switch (this) {
      case PipelineResult.canceled:
        return Icon(DevOpsIcons.cancelled, color: AppRouter.rootNavigator!.context.themeExtension.onBackground);
      case PipelineResult.failed:
        return Icon(DevOpsIcons.failed, color: Colors.red);
      case PipelineResult.none:
        return Icon(Icons.question_mark, color: Colors.grey);
      case PipelineResult.partiallySucceeded:
        return Icon(Icons.checklist, color: Colors.cyanAccent);
      case PipelineResult.succeeded:
        return Icon(DevOpsIcons.success, color: Colors.green);
      default:
        return Icon(Icons.question_mark, color: Colors.transparent);
    }
  }
}
