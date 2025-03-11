import 'dart:math';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/pipeline_approvals.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';

extension ApprovalExt on Approval {
  String get executionOrderDescription {
    if (minRequiredApprovers < steps.length) {
      return 'At least $minRequiredApprovers approvers must approve';
    }

    return 'All approvers must approve${executionOrder == 'inSequence' ? ' in sequence' : ''}';
  }

  int getLastStepTimestamp() => steps.fold(
        DateTime(1900).millisecondsSinceEpoch,
        (prev, step) => max(prev, (step.lastModifiedOn ?? DateTime.now()).millisecondsSinceEpoch),
      );
}

extension StepExt on ApprovalStep {
  bool get isCompleted => ['approved', 'rejected'].contains(status);

  Icon get statusIcon {
    switch (status) {
      case 'approved':
        return Icon(
          DevOpsIcons.success,
          color: Colors.green,
        );
      case 'rejected':
        return Icon(
          DevOpsIcons.failed,
          color: AppRouter.navigatorKey.currentContext!.colorScheme.error,
        );
      case 'pending':
        return Icon(
          DevOpsIcons.queued,
          color: Colors.blue,
        );
      case 'timedOut':
        return Icon(
          DevOpsIcons.skipped,
          color: AppRouter.rootNavigator!.context.themeExtension.onBackground,
        );

      default:
        return Icon(
          Icons.question_mark,
          color: Colors.transparent,
        );
    }
  }
}
