// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:http/http.dart';

class GetProjectsResponse {
  GetProjectsResponse({required this.projects});

  factory GetProjectsResponse.fromJson(Map<String, dynamic> source) =>
      GetProjectsResponse(projects: Project.listFromJson(source['value'])!);

  static List<Project> fromResponse(Response res) =>
      GetProjectsResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).projects;

  List<Project> projects;
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
