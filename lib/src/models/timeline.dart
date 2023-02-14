import 'dart:convert';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';

class GetTimelineResponse {
  factory GetTimelineResponse.fromJson(Map<String, dynamic> json) => GetTimelineResponse(
        records: List<Record>.from(
          (json['records'] as List<dynamic>).map((r) => Record.fromJson(r as Map<String, dynamic>)),
        ),
        lastChangedBy: json['lastChangedBy'] as String,
        lastChangedOn: DateTime.parse(json['lastChangedOn'] as String),
        id: json['id'] as String,
        changeId: json['changeId'] as int,
        url: json['url'] as String,
      );

  GetTimelineResponse({
    required this.records,
    required this.lastChangedBy,
    required this.lastChangedOn,
    required this.id,
    required this.changeId,
    required this.url,
  });

  factory GetTimelineResponse.fromRawJson(String str) =>
      GetTimelineResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  final List<Record> records;
  final String lastChangedBy;
  final DateTime lastChangedOn;
  final String id;
  final int changeId;
  final String url;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'records': List<dynamic>.from(records.map((x) => x.toJson())),
        'lastChangedBy': lastChangedBy,
        'lastChangedOn': lastChangedOn.toIso8601String(),
        'id': id,
        'changeId': changeId,
        'url': url,
      };
}

class Record {
  factory Record.fromRawJson(String str) => Record.fromJson(json.decode(str) as Map<String, dynamic>);

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
        result: json['result'] == null ? null : TaskResult.fromString(json['result'] as String),
        resultCode: json['resultCode'],
        changeId: json['changeId'] as int,
        lastModified: DateTime.parse(json['lastModified'] as String),
        workerName: json['workerName'] as String?,
        order: json['order'] as int?,
        details: json['details'],
        errorCount: json['errorCount'] as int,
        warningCount: json['warningCount'] as int,
        url: json['url'],
        log: json['log'] == null ? null : Log.fromJson(json['log'] as Map<String, dynamic>),
        task: json['task'] == null ? null : Task.fromJson(json['task'] as Map<String, dynamic>),
        attempt: json['attempt'] as int,
        identifier: json['identifier'] as String?,
        queueId: json['queueId'] as int?,
        issues: json['issues'] == null
            ? []
            : List<Issue>.from((json['issues'] as List<dynamic>).map((i) => Issue.fromJson(i as Map<String, dynamic>))),
      );

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
  final TaskResult? result;
  final dynamic resultCode;
  final int changeId;
  final DateTime lastModified;
  final String? workerName;
  final int? order;
  final dynamic details;
  final int errorCount;
  final int warningCount;
  final dynamic url;
  final Log? log;
  final Task? task;
  final int attempt;
  final String? identifier;
  final int? queueId;
  final List<Issue>? issues;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'previousAttempts': List<dynamic>.from(previousAttempts.map((x) => x)),
        'id': id,
        'parentId': parentId,
        'type': type,
        'name': name,
        'startTime': startTime?.toIso8601String(),
        'finishTime': finishTime?.toIso8601String(),
        'currentOperation': currentOperation,
        'percentComplete': percentComplete,
        'state': state,
        'result': result,
        'resultCode': resultCode,
        'changeId': changeId,
        'lastModified': lastModified.toIso8601String(),
        'workerName': workerName,
        'order': order,
        'details': details,
        'errorCount': errorCount,
        'warningCount': warningCount,
        'url': url,
        'log': log?.toJson(),
        'task': task?.toJson(),
        'attempt': attempt,
        'identifier': identifier,
        'queueId': queueId,
        'issues': issues == null ? <Issue>[] : List<dynamic>.from(issues!.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return 'Record(previousAttempts: $previousAttempts, id: $id, parentId: $parentId, type: $type, name: $name, startTime: $startTime, finishTime: $finishTime, currentOperation: $currentOperation, percentComplete: $percentComplete, state: $state, result: $result, resultCode: $resultCode, changeId: $changeId, lastModified: $lastModified, workerName: $workerName, order: $order, details: $details, errorCount: $errorCount, warningCount: $warningCount, url: $url, log: $log, task: $task, attempt: $attempt, identifier: $identifier, queueId: $queueId, issues: $issues)';
  }
}

class Issue {
  factory Issue.fromRawJson(String str) => Issue.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
        type: json['type'] as String,
        category: json['category'] as String?,
        message: json['message'] as String,
      );
  Issue({
    required this.type,
    this.category,
    required this.message,
  });

  final String type;
  final dynamic category;
  final String message;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'type': type,
        'category': category,
        'message': message,
      };
}

class Log {
  factory Log.fromRawJson(String str) => Log.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        id: json['id'] as int,
        type: json['type'] as String,
        url: json['url'] as String,
      );

  Log({
    required this.id,
    required this.type,
    required this.url,
  });

  final int id;
  final String type;
  final String url;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'url': url,
      };
}

class Task {
  factory Task.fromRawJson(String str) => Task.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        name: json['name'] as String,
        version: json['version'] as String,
      );
  Task({
    required this.id,
    required this.name,
    required this.version,
  });

  final String id;
  final String name;
  final String version;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
      };
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
    final size = 15.0;

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
enum TaskResult {
  abandoned('abandoned'),
  canceled('canceled'),
  failed('failed'),
  skipped('skipped'),
  succeeded('succeeded'),
  succeededWithIssues('succeededWithIssues');

  const TaskResult(this.stringValue);

  final String stringValue;

  static TaskResult fromString(String str) {
    return values.firstWhere((v) => v.stringValue == str);
  }

  @override
  String toString() {
    switch (this) {
      case TaskResult.abandoned:
        return 'Abandoned';
      case TaskResult.canceled:
        return 'Canceled';
      case TaskResult.failed:
        return 'Failed';
      case TaskResult.skipped:
        return 'Skipped';
      case TaskResult.succeeded:
        return 'Succeeded';
      case TaskResult.succeededWithIssues:
        return 'Succeeded with issues';
    }
  }

  Icon get icon {
    final size = 15.0;

    switch (this) {
      case TaskResult.abandoned:
      case TaskResult.canceled:
        return Icon(
          DevOpsIcons.cancelled,
          color: AppRouter.rootNavigator!.context.colorScheme.onBackground,
          size: size,
        );
      case TaskResult.failed:
        return Icon(
          DevOpsIcons.failed,
          color: Colors.red,
          size: size,
        );
      case TaskResult.skipped:
        return Icon(
          DevOpsIcons.skipped,
          color: AppRouter.rootNavigator!.context.colorScheme.onBackground,
          size: size,
        );
      case TaskResult.succeeded:
      case TaskResult.succeededWithIssues:
        return Icon(
          DevOpsIcons.success,
          color: Colors.green,
          size: size,
        );
    }
  }
}
