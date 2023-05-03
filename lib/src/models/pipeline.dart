import 'dart:convert';

import 'package:azure_devops/src/models/project.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GetPipelineResponse {
  factory GetPipelineResponse.fromJson(Map<String, dynamic> source) =>
      GetPipelineResponse(pipelines: Pipeline.listFromJson(json.decode(jsonEncode(source['value'])))!);
  GetPipelineResponse({required this.pipelines});

  final List<Pipeline> pipelines;
}

class Pipeline {
  factory Pipeline.fromJson(Map<String, dynamic> json) => Pipeline(
        triggerInfo: _TriggerInfo.fromJson(json['triggerInfo'] as Map<String, dynamic>),
        id: json['id'] as int?,
        buildNumber: json['buildNumber'] as String?,
        status: PipelineStatus.fromString(json['status'] as String),
        result: json['result'] == null ? null : PipelineResult.fromString(json['result'] as String),
        queueTime: DateTime.tryParse(json['queueTime']?.toString() ?? '')?.toLocal(),
        startTime: DateTime.tryParse(json['startTime']?.toString() ?? '')?.toLocal(),
        finishTime: DateTime.tryParse(json['finishTime']?.toString() ?? '')?.toLocal(),
        url: json['url'] as String?,
        definition: _Definition.fromJson(json['definition'] as Map<String, dynamic>),
        buildNumberRevision: json['buildNumberRevision'] as int?,
        project: Project.fromJson(json['project'] as Map<String, dynamic>),
        uri: json['uri'] as String?,
        sourceBranch: json['sourceBranch'] as String?,
        sourceVersion: json['sourceVersion'] as String?,
        queuePosition: int.tryParse(json['queuePosition']?.toString() ?? ''),
        priority: json['priority'] as String?,
        reason: json['reason'] as String?,
        requestedFor: _LastChangedBy.fromJson(json['requestedFor'] as Map<String, dynamic>),
        requestedBy: _LastChangedBy.fromJson(json['requestedBy'] as Map<String, dynamic>),
        repository: _Repository.fromJson(json['repository'] as Map<String, dynamic>),
        triggeredByBuild: json['triggeredByBuild'],
      );

  Pipeline({
    required this.triggerInfo,
    required this.id,
    required this.buildNumber,
    required this.status,
    required this.result,
    required this.queueTime,
    required this.startTime,
    required this.finishTime,
    required this.url,
    required this.definition,
    required this.buildNumberRevision,
    required this.project,
    required this.uri,
    required this.sourceBranch,
    required this.sourceVersion,
    this.queuePosition,
    required this.priority,
    required this.reason,
    required this.requestedFor,
    required this.requestedBy,
    required this.repository,
    required this.triggeredByBuild,
  });

  final _TriggerInfo? triggerInfo;
  final int? id;
  final String? buildNumber;
  final PipelineStatus? status;
  final PipelineResult? result;
  final DateTime? queueTime;
  final DateTime? startTime;
  final DateTime? finishTime;
  final String? url;
  final _Definition? definition;
  final int? buildNumberRevision;
  final Project? project;
  final String? uri;
  final String? sourceBranch;
  final String? sourceVersion;
  final int? queuePosition;
  final String? priority;
  final String? reason;
  final _LastChangedBy? requestedFor;
  final _LastChangedBy? requestedBy;
  final _Repository? repository;
  final dynamic triggeredByBuild;

  @visibleForTesting
  static Pipeline empty() {
    return Pipeline(
      triggerInfo: _TriggerInfo(ciSourceBranch: '', ciSourceSha: '', ciMessage: '', ciTriggerRepository: ''),
      id: 1,
      buildNumber: '123',
      status: PipelineStatus.none,
      result: PipelineResult.none,
      queueTime: DateTime(2000),
      startTime: null,
      finishTime: null,
      url: '',
      definition: null,
      buildNumberRevision: null,
      project: null,
      uri: null,
      sourceBranch: null,
      sourceVersion: null,
      priority: null,
      reason: null,
      requestedFor: _LastChangedBy(
        displayName: '',
        url: '',
        links: _LastChangedByLinks(avatar: _Badge(href: '')),
        id: '',
        uniqueName: '',
        imageUrl: '',
        descriptor: '',
      ),
      requestedBy: null,
      repository: null,
      triggeredByBuild: null,
    );
  }

  Pipeline copyWithStatus(PipelineStatus newStatus) {
    return copyWith(status: newStatus);
  }

  Pipeline copyWithResult(PipelineResult newResult) {
    return copyWith(result: newResult);
  }

  Pipeline copyWithRequestedFor(String newName) {
    return copyWith(requestedFor: requestedFor!.copyWith(displayName: newName));
  }

  static List<Pipeline>? listFromJson(
    dynamic json, {
    bool growable = true,
  }) {
    final result = <Pipeline>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Pipeline.fromJson(row as Map<String, dynamic>);
        result.add(value);
      }
    }
    return result.toList(growable: growable);
  }

  Map<String, dynamic> toJson() => {
        'triggerInfo': triggerInfo!.toJson(),
        'id': id,
        'buildNumber': buildNumber,
        'status': status,
        'result': result,
        'queueTime': queueTime?.toIso8601String(),
        'startTime': startTime?.toIso8601String(),
        'finishTime': finishTime?.toIso8601String(),
        'url': url,
        'definition': definition!.toJson(),
        'buildNumberRevision': buildNumberRevision,
        'project': project!.toJson(),
        'uri': uri,
        'sourceBranch': sourceBranch,
        'sourceVersion': sourceVersion,
        'queuePosition': queuePosition,
        'priority': priority,
        'reason': reason,
        'requestedFor': requestedFor!.toJson(),
        'requestedBy': requestedBy!.toJson(),
        'repository': repository!.toJson(),
        'triggeredByBuild': triggeredByBuild,
      };

  Pipeline copyWith({
    _TriggerInfo? triggerInfo,
    int? id,
    String? buildNumber,
    PipelineStatus? status,
    PipelineResult? result,
    DateTime? queueTime,
    DateTime? startTime,
    DateTime? finishTime,
    String? url,
    _Definition? definition,
    int? buildNumberRevision,
    Project? project,
    String? uri,
    String? sourceBranch,
    String? sourceVersion,
    int? queuePosition,
    String? priority,
    String? reason,
    _LastChangedBy? requestedFor,
    _LastChangedBy? requestedBy,
    _Repository? repository,
    dynamic triggeredByBuild,
  }) {
    return Pipeline(
      triggerInfo: triggerInfo ?? this.triggerInfo,
      id: id ?? this.id,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      result: result ?? this.result,
      queueTime: queueTime ?? this.queueTime,
      startTime: startTime ?? this.startTime,
      finishTime: finishTime ?? this.finishTime,
      url: url ?? this.url,
      definition: definition ?? this.definition,
      buildNumberRevision: buildNumberRevision ?? this.buildNumberRevision,
      project: project ?? this.project,
      uri: uri ?? this.uri,
      sourceBranch: sourceBranch ?? this.sourceBranch,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      queuePosition: queuePosition ?? this.queuePosition,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
      requestedFor: requestedFor ?? this.requestedFor,
      requestedBy: requestedBy ?? this.requestedBy,
      repository: repository ?? this.repository,
      triggeredByBuild: triggeredByBuild ?? this.triggeredByBuild,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pipeline &&
        other.triggerInfo == triggerInfo &&
        other.id == id &&
        other.buildNumber == buildNumber &&
        other.status == status &&
        other.result == result &&
        other.queueTime == queueTime &&
        other.startTime == startTime &&
        other.finishTime == finishTime &&
        other.url == url &&
        other.definition == definition &&
        other.buildNumberRevision == buildNumberRevision &&
        other.project == project &&
        other.uri == uri &&
        other.sourceBranch == sourceBranch &&
        other.sourceVersion == sourceVersion &&
        other.queuePosition == queuePosition &&
        other.priority == priority &&
        other.reason == reason &&
        other.requestedFor == requestedFor &&
        other.requestedBy == requestedBy &&
        other.repository == repository &&
        other.triggeredByBuild == triggeredByBuild;
  }

  @override
  int get hashCode {
    return triggerInfo.hashCode ^
        id.hashCode ^
        buildNumber.hashCode ^
        status.hashCode ^
        result.hashCode ^
        queueTime.hashCode ^
        startTime.hashCode ^
        finishTime.hashCode ^
        url.hashCode ^
        definition.hashCode ^
        buildNumberRevision.hashCode ^
        project.hashCode ^
        uri.hashCode ^
        sourceBranch.hashCode ^
        sourceVersion.hashCode ^
        queuePosition.hashCode ^
        priority.hashCode ^
        reason.hashCode ^
        requestedFor.hashCode ^
        requestedBy.hashCode ^
        repository.hashCode ^
        triggeredByBuild.hashCode;
  }

  @override
  String toString() {
    return 'Pipeline(triggerInfo: $triggerInfo, id: $id, buildNumber: $buildNumber, status: $status, result: $result, queueTime: $queueTime, startTime: $startTime, finishTime: $finishTime, url: $url, definition: $definition, buildNumberRevision: $buildNumberRevision, project: $project, uri: $uri, sourceBranch: $sourceBranch, sourceVersion: $sourceVersion, queuePosition: $queuePosition, priority: $priority, reason: $reason, requestedFor: $requestedFor, requestedBy: $requestedBy, repository: $repository, triggeredByBuild: $triggeredByBuild)';
  }
}

class _Definition {
  factory _Definition.fromJson(Map<String, dynamic> json) => _Definition(
        drafts: json['drafts'] == null ? [] : List<dynamic>.from((json['drafts'] as List<dynamic>).map((x) => x)),
        id: json['id'] as int?,
        name: json['name'] as String?,
        url: json['url'] as String?,
        uri: json['uri'] as String?,
        path: json['path'] as String?,
        type: json['type'] as String?,
        queueStatus: json['queueStatus'] as String?,
        revision: json['revision'] as int?,
        project: Project.fromJson(json['project'] as Map<String, dynamic>),
      );

  _Definition({
    required this.drafts,
    required this.id,
    required this.name,
    required this.url,
    required this.uri,
    required this.path,
    required this.type,
    required this.queueStatus,
    required this.revision,
    required this.project,
  });

  final List<dynamic>? drafts;
  final int? id;
  final String? name;
  final String? url;
  final String? uri;
  final String? path;
  final String? type;
  final String? queueStatus;
  final int? revision;
  final Project? project;

  Map<String, dynamic> toJson() => {
        'drafts': drafts == null ? <dynamic>[] : List<dynamic>.from(drafts!.map((x) => x)),
        'id': id,
        'name': name,
        'url': url,
        'uri': uri,
        'path': path,
        'type': type,
        'queueStatus': queueStatus,
        'revision': revision,
        'project': project!.toJson(),
      };

  @override
  String toString() {
    return '_Definition(drafts: $drafts, id: $id, name: $name, url: $url, uri: $uri, path: $path, type: $type, queueStatus: $queueStatus, revision: $revision, project: $project)';
  }
}

class _LastChangedBy {
  factory _LastChangedBy.fromJson(Map<String, dynamic> json) => _LastChangedBy(
        displayName: json['displayName'] as String?,
        url: json['url'] as String?,
        links: _LastChangedByLinks.fromJson(json['_links'] as Map<String, dynamic>),
        id: json['id'] as String?,
        uniqueName: json['uniqueName'] as String?,
        imageUrl: json['imageUrl'] as String?,
        descriptor: json['descriptor'] as String?,
      );

  _LastChangedBy({
    required this.displayName,
    required this.url,
    required this.links,
    required this.id,
    required this.uniqueName,
    required this.imageUrl,
    required this.descriptor,
  });

  final String? displayName;
  final String? url;
  final _LastChangedByLinks? links;
  final String? id;
  final String? uniqueName;
  final String? imageUrl;
  final String? descriptor;

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'url': url,
        '_links': links!.toJson(),
        'id': id,
        'uniqueName': uniqueName,
        'imageUrl': imageUrl,
        'descriptor': descriptor,
      };

  _LastChangedBy copyWith({
    String? displayName,
    String? url,
    _LastChangedByLinks? links,
    String? id,
    String? uniqueName,
    String? imageUrl,
    String? descriptor,
  }) {
    return _LastChangedBy(
      displayName: displayName ?? this.displayName,
      url: url ?? this.url,
      links: links ?? this.links,
      id: id ?? this.id,
      uniqueName: uniqueName ?? this.uniqueName,
      imageUrl: imageUrl ?? this.imageUrl,
      descriptor: descriptor ?? this.descriptor,
    );
  }

  @override
  String toString() {
    return '_LastChangedBy(displayName: $displayName, url: $url, links: $links, id: $id, uniqueName: $uniqueName, imageUrl: $imageUrl, descriptor: $descriptor)';
  }
}

class _LastChangedByLinks {
  factory _LastChangedByLinks.fromJson(Map<String, dynamic> json) => _LastChangedByLinks(
        avatar: _Badge.fromJson(json['avatar'] as Map<String, dynamic>),
      );

  _LastChangedByLinks({
    required this.avatar,
  });

  final _Badge? avatar;

  Map<String, dynamic> toJson() => {
        'avatar': avatar!.toJson(),
      };

  @override
  String toString() => '_LastChangedByLinks(avatar: $avatar)';
}

class _Badge {
  factory _Badge.fromJson(Map<String, dynamic> json) => _Badge(
        href: json['href'] as String?,
      );

  _Badge({
    required this.href,
  });

  final String? href;

  Map<String, dynamic> toJson() => {
        'href': href,
      };

  @override
  String toString() => '_Badge(href: $href)';
}

class _Repository {
  factory _Repository.fromJson(Map<String, dynamic> json) => _Repository(
        id: json['id'] as String?,
        type: json['type'] as String?,
        name: json['name'] as String?,
        url: json['url'] as String?,
        clean: json['clean'],
        checkoutSubmodules: json['checkoutSubmodules'] as bool?,
      );

  _Repository({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
    required this.clean,
    required this.checkoutSubmodules,
  });

  final String? id;
  final String? type;
  final String? name;
  final String? url;
  final dynamic clean;
  final bool? checkoutSubmodules;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'url': url,
        'clean': clean,
        'checkoutSubmodules': checkoutSubmodules,
      };

  @override
  String toString() {
    return '_Repository(id: $id, type: $type, name: $name, url: $url, clean: $clean, checkoutSubmodules: $checkoutSubmodules)';
  }
}

class _TriggerInfo {
  factory _TriggerInfo.fromJson(Map<String, dynamic> json) => _TriggerInfo(
        ciSourceBranch: json['ci.sourceBranch'] as String?,
        ciSourceSha: json['ci.sourceSha'] as String?,
        ciMessage: json['ci.message'] as String?,
        ciTriggerRepository: json['ci.triggerRepository'] as String?,
      );

  _TriggerInfo({
    required this.ciSourceBranch,
    required this.ciSourceSha,
    required this.ciMessage,
    required this.ciTriggerRepository,
  });

  final String? ciSourceBranch;
  final String? ciSourceSha;
  final String? ciMessage;
  final String? ciTriggerRepository;

  Map<String, dynamic> toJson() => {
        'ci.sourceBranch': ciSourceBranch,
        'ci.sourceSha': ciSourceSha,
        'ci.message': ciMessage,
        'ci.triggerRepository': ciTriggerRepository,
      };

  _TriggerInfo copyWith({
    String? ciSourceBranch,
    String? ciSourceSha,
    String? ciMessage,
    String? ciTriggerRepository,
  }) {
    return _TriggerInfo(
      ciSourceBranch: ciSourceBranch ?? this.ciSourceBranch,
      ciSourceSha: ciSourceSha ?? this.ciSourceSha,
      ciMessage: ciMessage ?? this.ciMessage,
      ciTriggerRepository: ciTriggerRepository ?? this.ciTriggerRepository,
    );
  }

  @override
  String toString() {
    return '_TriggerInfo(ciSourceBranch: $ciSourceBranch, ciSourceSha: $ciSourceSha, ciMessage: $ciMessage, ciTriggerRepository: $ciTriggerRepository)';
  }
}

/// The build result.
enum PipelineResult {
  all('all'),
  none('none'),
  succeeded('succeeded'),
  partiallySucceeded('partiallySucceeded'),
  failed('failed'),
  canceled('canceled');

  const PipelineResult(this.stringValue);

  final String stringValue;

  static PipelineResult fromString(String str) {
    return values.firstWhere((v) => v.stringValue == str);
  }

  @override
  String toString() {
    switch (this) {
      case PipelineResult.none:
        return 'None';
      case PipelineResult.succeeded:
        return 'Succeded';
      case PipelineResult.partiallySucceeded:
        return 'Partially Succeded';
      case PipelineResult.failed:
        return 'Failed';
      case PipelineResult.canceled:
        return 'Canceled';
      case PipelineResult.all:
        return 'All';
    }
  }
}

/// The status of the build.
enum PipelineStatus {
  all('all'),
  none('none'),
  inProgress('inProgress'),
  completed('completed'),
  cancelling('cancelling'),
  postponed('postponed'),
  notStarted('notStarted');

  const PipelineStatus(this.stringValue);

  final String stringValue;

  static PipelineStatus fromString(String str) {
    return values.firstWhere((v) => v.stringValue == str);
  }

  @override
  String toString() {
    switch (this) {
      case PipelineStatus.none:
        return 'None';
      case PipelineStatus.inProgress:
        return 'In progress';
      case PipelineStatus.completed:
        return 'Completed';
      case PipelineStatus.cancelling:
        return 'Cancelling';
      case PipelineStatus.postponed:
        return 'Postponed';
      case PipelineStatus.notStarted:
        return 'Not started';
      case PipelineStatus.all:
        return 'All';
    }
  }
}
