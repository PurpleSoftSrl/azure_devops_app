// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class GetTimelineResponse {
  GetTimelineResponse({
    required this.records,
    required this.lastChangedBy,
    required this.lastChangedOn,
    required this.id,
    required this.changeId,
  });

  factory GetTimelineResponse.fromJson(Map<String, dynamic> json) => GetTimelineResponse(
        records: List<Record>.from(
          (json['records'] as List<dynamic>).map((r) => Record.fromJson(r as Map<String, dynamic>)),
        ),
        lastChangedBy: json['lastChangedBy'] as String,
        lastChangedOn: DateTime.parse(json['lastChangedOn'] as String),
        id: json['id'] as String,
        changeId: json['changeId'] as int,
      );

  static List<Record> fromResponse(Response res) =>
      GetTimelineResponse.fromJson(json.decode(res.body) as Map<String, dynamic>).records;

  final List<Record> records;
  final String lastChangedBy;
  final DateTime lastChangedOn;
  final String id;
  final int changeId;
}

class Record {
  Record({
    required this.previousAttempts,
    required this.id,
    this.parentId,
    required this.type,
    required this.name,
    required this.startTime,
    required this.finishTime,
    this.currentOperation,
    this.percentComplete,
    required this.state,
    required this.result,
    this.resultCode,
    required this.changeId,
    required this.lastModified,
    this.workerName,
    this.order,
    this.details,
    required this.errorCount,
    required this.warningCount,
    this.url,
    this.log,
    this.task,
    required this.attempt,
    this.identifier,
    this.queueId,
    this.issues,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        previousAttempts: List<dynamic>.from((json['previousAttempts'] as List<dynamic>).map((x) => x)),
        id: json['id'] as String,
        parentId: json['parentId'] as String?,
        type: json['type'] as String,
        name: json['name'] as String,
        startTime: json['startTime'] == null ? null : DateTime.parse(json['startTime'] as String),
        finishTime: json['finishTime'] == null ? null : DateTime.parse(json['finishTime'] as String),
        currentOperation: json['currentOperation'],
        percentComplete: json['percentComplete'] as int?,
        state: TaskStatus.fromString(json['state'] as String),
        result: json['result'] == null ? null : _TaskResult.fromString(json['result'] as String),
        resultCode: json['resultCode'],
        changeId: json['changeId'] as int,
        lastModified: DateTime.parse(json['lastModified'] as String),
        workerName: json['workerName'] as String?,
        order: json['order'] as int?,
        details: json['details'],
        errorCount: json['errorCount'] as int,
        warningCount: json['warningCount'] as int,
        url: json['url'],
        log: json['log'] == null ? null : _Log.fromJson(json['log'] as Map<String, dynamic>),
        task: json['task'] == null ? null : _Task.fromJson(json['task'] as Map<String, dynamic>),
        attempt: json['attempt'] as int,
        identifier: json['identifier'] as String?,
        queueId: json['queueId'] as int?,
        issues: json['issues'] == null
            ? []
            : List<_Issue>.from(
                (json['issues'] as List<dynamic>).map((i) => _Issue.fromJson(i as Map<String, dynamic>)),
              ),
      );

  final List<dynamic> previousAttempts;
  final String id;
  final String? parentId;
  final String type;
  final String name;
  final DateTime? startTime;
  final DateTime? finishTime;
  final dynamic currentOperation;
  final int? percentComplete;
  final TaskStatus state;
  final _TaskResult? result;
  final dynamic resultCode;
  final int changeId;
  final DateTime lastModified;
  final String? workerName;
  final int? order;
  final dynamic details;
  final int errorCount;
  final int warningCount;
  final dynamic url;
  final _Log? log;
  final _Task? task;
  final int attempt;
  final String? identifier;
  final int? queueId;
  final List<_Issue>? issues;

  @override
  String toString() {
    return 'Record(previousAttempts: $previousAttempts, id: $id, parentId: $parentId, type: $type, name: $name, startTime: $startTime, finishTime: $finishTime, currentOperation: $currentOperation, percentComplete: $percentComplete, state: $state, result: $result, resultCode: $resultCode, changeId: $changeId, lastModified: $lastModified, workerName: $workerName, order: $order, details: $details, errorCount: $errorCount, warningCount: $warningCount, url: $url, log: $log, task: $task, attempt: $attempt, identifier: $identifier, queueId: $queueId, issues: $issues)';
  }
}

class _Issue {
  _Issue({
    required this.type,
    this.category,
    required this.message,
  });

  factory _Issue.fromJson(Map<String, dynamic> json) => _Issue(
        type: json['type'] as String,
        category: json['category'] as String?,
        message: json['message'] as String,
      );

  final String type;
  final dynamic category;
  final String message;
}

class _Log {
  _Log({
    required this.id,
    required this.type,
    required this.url,
  });

  factory _Log.fromJson(Map<String, dynamic> json) => _Log(
        id: json['id'] as int,
        type: json['type'] as String,
        url: json['url'] as String,
      );

  final int id;
  final String type;
  final String url;
}

class _Task {
  _Task({
    required this.id,
    required this.name,
    required this.version,
  });

  factory _Task.fromJson(Map<String, dynamic> json) => _Task(
        id: json['id'] as String,
        name: json['name'] as String,
        version: json['version'] as String,
      );

  final String id;
  final String name;
  final String version;
}

/// The status of a single task.
enum TaskStatus {
  inProgress('inProgress'),
  completed('completed'),
  pending('pending');

  const TaskStatus(this.stringValue);

  final String stringValue;

  static TaskStatus fromString(String str) {
    return values.firstWhere((v) => v.stringValue == str);
  }

  @override
  String toString() {
    switch (this) {
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.pending:
        return 'Not started';
    }
  }

  Icon get icon {
    const size = 15.0;

    switch (this) {
      case TaskStatus.inProgress:
        return Icon(
          DevOpsIcons.running,
          color: Colors.blue,
          size: size,
        );
      case TaskStatus.completed:
        return Icon(
          DevOpsIcons.success,
          color: Colors.green,
          size: size,
        );
      case TaskStatus.pending:
        return Icon(
          DevOpsIcons.queued,
          color: Colors.blue,
          size: size,
        );
    }
  }
}

/// The result of a task/job/stage.
enum _TaskResult {
  abandoned('abandoned'),
  canceled('canceled'),
  failed('failed'),
  skipped('skipped'),
  succeeded('succeeded'),
  succeededWithIssues('succeededWithIssues');

  const _TaskResult(this.stringValue);

  final String stringValue;

  static _TaskResult fromString(String str) {
    return values.firstWhere((v) => v.stringValue == str);
  }

  @override
  String toString() {
    switch (this) {
      case _TaskResult.abandoned:
        return 'Abandoned';
      case _TaskResult.canceled:
        return 'Canceled';
      case _TaskResult.failed:
        return 'Failed';
      case _TaskResult.skipped:
        return 'Skipped';
      case _TaskResult.succeeded:
        return 'Succeeded';
      case _TaskResult.succeededWithIssues:
        return 'Succeeded with issues';
    }
  }

  Icon get icon {
    const size = 15.0;

    switch (this) {
      case _TaskResult.abandoned:
      case _TaskResult.canceled:
        return Icon(
          DevOpsIcons.cancelled,
          color: AppRouter.rootNavigator!.context.colorScheme.onBackground,
          size: size,
        );
      case _TaskResult.failed:
        return Icon(
          DevOpsIcons.failed,
          color: Colors.red,
          size: size,
        );
      case _TaskResult.skipped:
        return Icon(
          DevOpsIcons.skipped,
          color: AppRouter.rootNavigator!.context.colorScheme.onBackground,
          size: size,
        );
      case _TaskResult.succeeded:
      case _TaskResult.succeededWithIssues:
        return Icon(
          DevOpsIcons.success,
          color: Colors.green,
          size: size,
        );
    }
  }
}
