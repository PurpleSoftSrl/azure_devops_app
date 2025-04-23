import 'dart:convert';

import 'package:http/http.dart';

class GetRepositoriesResponse {
  GetRepositoriesResponse({required this.repositories});

  factory GetRepositoriesResponse.fromJson(Map<String, dynamic> source) =>
      GetRepositoriesResponse(repositories: GitRepository.listFromJson(json.decode(jsonEncode(source['value'])))!);

  static List<GitRepository> fromResponse(Response res) =>
      GetRepositoriesResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>).repositories;

  final List<GitRepository> repositories;

  @override
  String toString() => 'GetRepositoriesResponse(repositories: $repositories)';
}

class GitRepository {
  GitRepository({
    this.defaultBranch,
    this.id,
    this.isDisabled,
    this.isFork,
    this.name,
    this.parentRepository,
    this.project,
    this.remoteUrl,
    this.size,
    this.url,
  });

  String? defaultBranch;
  String? id;
  bool? isDisabled;
  bool? isFork;
  String? name;
  _GitRepositoryRef? parentRepository;
  TeamProjectReference? project;
  String? remoteUrl;
  int? size;
  String? url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitRepository &&
          other.defaultBranch == defaultBranch &&
          other.id == id &&
          other.isDisabled == isDisabled &&
          other.isFork == isFork &&
          other.name == name &&
          other.parentRepository == parentRepository &&
          other.project == project &&
          other.remoteUrl == remoteUrl &&
          other.size == size;

  @override
  int get hashCode =>
      (defaultBranch == null ? 0 : defaultBranch!.hashCode) +
      (id == null ? 0 : id!.hashCode) +
      (isDisabled == null ? 0 : isDisabled!.hashCode) +
      (isFork == null ? 0 : isFork!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (parentRepository == null ? 0 : parentRepository!.hashCode) +
      (project == null ? 0 : project!.hashCode) +
      (remoteUrl == null ? 0 : remoteUrl!.hashCode) +
      (size == null ? 0 : size!.hashCode) +
      (url == null ? 0 : url!.hashCode);

  @override
  String toString() =>
      'GitRepository[defaultBranch=$defaultBranch, id=$id, isDisabled=$isDisabled, isFork=$isFork, name=$name, parentRepository=$parentRepository, project=$project, remoteUrl=$remoteUrl, size=$size, url=$url]';

  static GitRepository? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return GitRepository(
        defaultBranch: json['defaultBranch'] as String?,
        id: json['id'] as String?,
        isDisabled: json['isDisabled'] as bool?,
        isFork: json['isFork'] as bool?,
        name: json['name'] as String?,
        parentRepository: _GitRepositoryRef.fromJson(json['parentRepository']),
        project: TeamProjectReference.fromJson(json['project']),
        remoteUrl: json['remoteUrl'] as String?,
        size: json['size'] as int?,
        url: json['url'] as String?,
      );
    }
    return null;
  }

  static List<GitRepository>? listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GitRepository>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GitRepository.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

class _GitRepositoryRef {
  _GitRepositoryRef({
    this.id,
    this.isFork,
    this.name,
    this.project,
    this.remoteUrl,
    this.url,
  });

  String? id;
  bool? isFork;
  String? name;
  TeamProjectReference? project;
  String? remoteUrl;
  String? url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GitRepositoryRef &&
          other.id == id &&
          other.isFork == isFork &&
          other.name == name &&
          other.project == project &&
          other.remoteUrl == remoteUrl &&
          other.url == url;

  @override
  int get hashCode =>
      (id == null ? 0 : id!.hashCode) +
      (isFork == null ? 0 : isFork!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (project == null ? 0 : project!.hashCode) +
      (remoteUrl == null ? 0 : remoteUrl!.hashCode) +
      (url == null ? 0 : url!.hashCode);

  @override
  String toString() =>
      'GitRepositoryRef[id=$id, isFork=$isFork, name=$name, project=$project, remoteUrl=$remoteUrl, url=$url]';

  static _GitRepositoryRef? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return _GitRepositoryRef(
        id: json['id'] as String?,
        isFork: json['isFork'] as bool?,
        name: json['name'] as String?,
        project: TeamProjectReference.fromJson(json['project']),
        remoteUrl: json['remoteUrl'] as String?,
        url: json['url'] as String?,
      );
    }
    return null;
  }
}

class TeamProjectReference {
  TeamProjectReference({
    this.abbreviation,
    this.defaultTeamImageUrl,
    this.description,
    this.id,
    this.lastUpdateTime,
    this.name,
    this.revision,
    this.url,
    this.visibility,
  });

  String? abbreviation;
  String? defaultTeamImageUrl;
  String? description;
  String? id;
  DateTime? lastUpdateTime;
  String? name;
  int? revision;
  String? url;
  _TeamProjectReferenceVisibilityEnum? visibility;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamProjectReference &&
          other.abbreviation == abbreviation &&
          other.defaultTeamImageUrl == defaultTeamImageUrl &&
          other.description == description &&
          other.id == id &&
          other.lastUpdateTime == lastUpdateTime &&
          other.name == name &&
          other.revision == revision &&
          other.url == url &&
          other.visibility == visibility;

  @override
  int get hashCode =>
      (abbreviation == null ? 0 : abbreviation!.hashCode) +
      (defaultTeamImageUrl == null ? 0 : defaultTeamImageUrl!.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (id == null ? 0 : id!.hashCode) +
      (lastUpdateTime == null ? 0 : lastUpdateTime!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (revision == null ? 0 : revision!.hashCode) +
      (url == null ? 0 : url!.hashCode) +
      (visibility == null ? 0 : visibility!.hashCode);

  @override
  String toString() =>
      'TeamProjectReference[abbreviation=$abbreviation, defaultTeamImageUrl=$defaultTeamImageUrl, description=$description, id=$id, lastUpdateTime=$lastUpdateTime, name=$name, revision=$revision, url=$url, visibility=$visibility]';

  static TeamProjectReference? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return TeamProjectReference(
        abbreviation: json['abbreviation'] as String?,
        defaultTeamImageUrl: json['defaultTeamImageUrl'] as String?,
        description: json['description'] as String?,
        id: json['id'] as String,
        lastUpdateTime:
            json['lastUpdateTime'] == null ? null : DateTime.parse(json['lastUpdateTime'].toString()).toLocal(),
        name: json['name'] as String,
        revision: json['revision'] as int?,
        url: json['url'] as String?,
        visibility: _TeamProjectReferenceVisibilityEnum.fromJson(json['visibility']),
      );
    }
    return null;
  }
}

// ignore: use_enums
class _TeamProjectReferenceVisibilityEnum {
  const _TeamProjectReferenceVisibilityEnum._(this.value);

  final String value;

  @override
  String toString() => value;

  static const private = _TeamProjectReferenceVisibilityEnum._('private');
  static const public = _TeamProjectReferenceVisibilityEnum._('public');

  static _TeamProjectReferenceVisibilityEnum? fromJson(dynamic value) =>
      _TeamProjectReferenceVisibilityEnumTypeTransformer().decode(value);
}

class _TeamProjectReferenceVisibilityEnumTypeTransformer {
  factory _TeamProjectReferenceVisibilityEnumTypeTransformer() =>
      _instance ??= const _TeamProjectReferenceVisibilityEnumTypeTransformer._();

  const _TeamProjectReferenceVisibilityEnumTypeTransformer._();

  String encode(_TeamProjectReferenceVisibilityEnum data) => data.value;

  _TeamProjectReferenceVisibilityEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case 'private':
          return _TeamProjectReferenceVisibilityEnum.private;
        case 'public':
          return _TeamProjectReferenceVisibilityEnum.public;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  static _TeamProjectReferenceVisibilityEnumTypeTransformer? _instance;
}
