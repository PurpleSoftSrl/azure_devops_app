import 'dart:convert';

import 'package:azure_devops/src/models/repository.dart';
import 'package:http/http.dart';

class GetProjectsResponse {
  GetProjectsResponse({required this.projects});

  factory GetProjectsResponse.fromJson(Map<String, dynamic> source) =>
      GetProjectsResponse(projects: Project.listFromJson(source['value'])!);

  static List<Project> fromResponse(Response res) =>
      GetProjectsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).projects;

  List<Project> projects;
}

class ProjectDetail {
  ProjectDetail({
    required this.project,
    this.gitmetrics,
    this.workMetrics,
    this.pipelinesMetrics,
  });

  final Project project;
  final Gitmetrics? gitmetrics;
  final WorkMetrics? workMetrics;
  final PipelinesMetrics? pipelinesMetrics;
}

class Project {
  Project({
    this.id,
    this.name,
    this.description,
    this.url,
    this.state,
    this.revision,
    this.visibility,
    this.lastUpdateTime,
    this.defaultTeam,
    this.defaultTeamImageUrl,
  });

  factory Project.all() => Project(name: 'All');

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        url: json['url'] as String?,
        state: json['state'] as String?,
        revision: json['revision'] as int?,
        visibility: json['visibility'] as String?,
        lastUpdateTime:
            json['lastUpdateTime'] == null ? null : DateTime.parse(json['lastUpdateTime'].toString()).toLocal(),
        defaultTeamImageUrl: json['defaultTeamImageUrl'] as String?,
        defaultTeam:
            json['defaultTeam'] == null ? null : _DefaultTeam.fromJson(json['defaultTeam'] as Map<String, dynamic>),
      );

  final String? id;
  final String? name;
  final String? description;
  final String? url;
  final String? state;
  final int? revision;
  final String? visibility;
  final DateTime? lastUpdateTime;
  final _DefaultTeam? defaultTeam;
  final String? defaultTeamImageUrl;

  static Project fromResponse(Response res) => Project.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  static Project fromRepository(TeamProjectReference project) {
    return Project(
      id: project.id,
      name: project.name,
      url: project.url,
      revision: project.revision,
      lastUpdateTime: project.lastUpdateTime,
      defaultTeamImageUrl: project.defaultTeamImageUrl,
    );
  }

  static List<Project>? listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Project>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Project.fromJson(row as Map<String, dynamic>);
        result.add(value);
      }
    }
    return result.toList(growable: growable);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'url': url,
        'state': state,
        'revision': revision,
        'visibility': visibility,
        'lastUpdateTime': lastUpdateTime?.toIso8601String(),
        'defaultTeam': defaultTeam?.toJson(),
        'defaultTeamImageUrl': defaultTeamImageUrl,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, description: $description, url: $url, state: $state, revision: $revision, visibility: $visibility, lastUpdateTime: $lastUpdateTime, defaultTeam: $defaultTeam, defaultTeamImageUrl: $defaultTeamImageUrl)';
  }
}

class _DefaultTeam {
  _DefaultTeam({
    required this.id,
    required this.name,
    required this.url,
  });

  factory _DefaultTeam.fromJson(Map<String, dynamic> source) => _DefaultTeam.fromMap(source);

  factory _DefaultTeam.fromMap(Map<String, dynamic> map) {
    return _DefaultTeam(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String url;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => '_DefaultTeam(id: $id, name: $name, url: $url)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _DefaultTeam && other.id == id && other.name == name && other.url == url;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ url.hashCode;
}

class CommitsAndWorkItems {
  CommitsAndWorkItems({required this.dataProviders});

  factory CommitsAndWorkItems.fromResponse(Response res) =>
      CommitsAndWorkItems.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory CommitsAndWorkItems.fromJson(Map<String, dynamic> json) => CommitsAndWorkItems(
        dataProviders: _DataProviders.fromJson(json['dataProviders'] as Map<String, dynamic>),
      );

  final _DataProviders dataProviders;
}

class _DataProviders {
  _DataProviders({
    required this.workItemsSummary,
    required this.commitsSummary,
  });

  factory _DataProviders.fromJson(Map<String, dynamic> json) {
    final workItems = json['ms.vss-work-web.work-item-metrics-data-provider-verticals'];
    final commits = json['ms.vss-code-web.code-metrics-data-provider-verticals'];
    return _DataProviders(
      workItemsSummary: workItems == null ? null : _WorkItemsSummary.fromJson(workItems as Map<String, dynamic>),
      commitsSummary: commits == null ? null : _CommitsSummary.fromJson(commits as Map<String, dynamic>),
    );
  }

  final _WorkItemsSummary? workItemsSummary;
  final _CommitsSummary? commitsSummary;
}

class _CommitsSummary {
  _CommitsSummary({this.gitmetrics});

  factory _CommitsSummary.fromJson(Map<String, dynamic> json) => _CommitsSummary(
        gitmetrics: json['gitmetrics'] == null ? null : Gitmetrics.fromJson(json['gitmetrics'] as Map<String, dynamic>),
      );

  final Gitmetrics? gitmetrics;
}

class Gitmetrics {
  Gitmetrics({
    required this.commitsPushedCount,
    required this.pullRequestsCreatedCount,
    required this.pullRequestsCompletedCount,
    required this.authorsCount,
  });

  factory Gitmetrics.fromJson(Map<String, dynamic> json) => Gitmetrics(
        commitsPushedCount: json['commitsPushedCount'] as int? ?? 0,
        pullRequestsCreatedCount: json['pullRequestsCreatedCount'] as int? ?? 0,
        pullRequestsCompletedCount: json['pullRequestsCompletedCount'] as int? ?? 0,
        authorsCount: json['authorsCount'] as int? ?? 0,
      );

  final int commitsPushedCount;
  final int pullRequestsCreatedCount;
  final int pullRequestsCompletedCount;
  final int authorsCount;
}

class _WorkItemsSummary {
  _WorkItemsSummary({this.workMetrics});

  factory _WorkItemsSummary.fromJson(Map<String, dynamic> json) => _WorkItemsSummary(
        workMetrics:
            json['workMetrics'] == null ? null : WorkMetrics.fromJson(json['workMetrics'] as Map<String, dynamic>),
      );

  final WorkMetrics? workMetrics;
}

class WorkMetrics {
  WorkMetrics({
    required this.workItemsCreated,
    required this.workItemsCompleted,
  });

  factory WorkMetrics.fromJson(Map<String, dynamic> json) => WorkMetrics(
        workItemsCreated: json['workItemsCreated'] as int? ?? 0,
        workItemsCompleted: json['workItemsCompleted'] as int? ?? 0,
      );

  final int workItemsCreated;
  final int workItemsCompleted;
}

class PipelinesSummary {
  PipelinesSummary({required this.metrics});

  factory PipelinesSummary.fromResponse(Response res) =>
      PipelinesSummary.fromJson(json.decode(res.body) as Map<String, dynamic>);

  factory PipelinesSummary.fromJson(Map<String, dynamic> json) => PipelinesSummary(
        metrics: List<_Metric>.from(
          (json['value'] as List<dynamic>).map((p) => _Metric.fromJson(p as Map<String, dynamic>)),
        ),
      );

  final List<_Metric> metrics;
}

class _Metric {
  _Metric({
    required this.name,
    required this.intValue,
    this.date,
  });

  factory _Metric.fromJson(Map<String, dynamic> json) => _Metric(
        name: json['name'] as String,
        intValue: json['intValue'] as int? ?? 0,
        date: json['date'] == null ? null : DateTime.parse(json['date']!.toString()),
      );

  final String name;
  final int intValue;
  final DateTime? date;
}

class PipelinesMetrics {
  PipelinesMetrics({
    required this.total,
    required this.successful,
    required this.partiallySuccessful,
    required this.failed,
    required this.canceled,
  });

  final int total;
  final int successful;
  final int partiallySuccessful;
  final int failed;
  final int canceled;
}
