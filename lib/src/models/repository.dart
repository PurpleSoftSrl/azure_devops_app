import 'dart:convert';

class GetRepositoriesResponse {
  factory GetRepositoriesResponse.fromJson(Map<String, dynamic> source) =>
      GetRepositoriesResponse(repositories: GitRepository.listFromJson(json.decode(jsonEncode(source['value'])))!);
  GetRepositoriesResponse({
    required this.repositories,
  });

  final List<GitRepository> repositories;

  @override
  String toString() => 'GetRepositoriesResponse(repositories: $repositories)';
}

class GitRepository {
  /// Returns a new [GitRepository] instance.
  GitRepository({
    this.links,
    this.defaultBranch,
    this.id,
    this.isDisabled,
    this.isFork,
    this.name,
    this.parentRepository,
    this.project,
    this.remoteUrl,
    this.size,
    this.sshUrl,
    this.url,
    this.validRemoteUrls = const [],
    this.webUrl,
  });

  _ReferenceLinks? links;

  String? defaultBranch;

  String? id;

  bool? isDisabled;

  bool? isFork;

  String? name;

  _GitRepositoryRef? parentRepository;

  _TeamProjectReference? project;

  String? remoteUrl;

  int? size;

  String? sshUrl;

  String? url;

  List<String> validRemoteUrls;

  String? webUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitRepository &&
          other.links == links &&
          other.defaultBranch == defaultBranch &&
          other.id == id &&
          other.isDisabled == isDisabled &&
          other.isFork == isFork &&
          other.name == name &&
          other.parentRepository == parentRepository &&
          other.project == project &&
          other.remoteUrl == remoteUrl &&
          other.size == size &&
          other.sshUrl == sshUrl &&
          other.url == url &&
          other.validRemoteUrls == validRemoteUrls &&
          other.webUrl == webUrl;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (links == null ? 0 : links!.hashCode) +
      (defaultBranch == null ? 0 : defaultBranch!.hashCode) +
      (id == null ? 0 : id!.hashCode) +
      (isDisabled == null ? 0 : isDisabled!.hashCode) +
      (isFork == null ? 0 : isFork!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (parentRepository == null ? 0 : parentRepository!.hashCode) +
      (project == null ? 0 : project!.hashCode) +
      (remoteUrl == null ? 0 : remoteUrl!.hashCode) +
      (size == null ? 0 : size!.hashCode) +
      (sshUrl == null ? 0 : sshUrl!.hashCode) +
      (url == null ? 0 : url!.hashCode) +
      (validRemoteUrls.hashCode) +
      (webUrl == null ? 0 : webUrl!.hashCode);

  @override
  String toString() =>
      'GitRepository[links=$links, defaultBranch=$defaultBranch, id=$id, isDisabled=$isDisabled, isFork=$isFork, name=$name, parentRepository=$parentRepository, project=$project, remoteUrl=$remoteUrl, size=$size, sshUrl=$sshUrl, url=$url, validRemoteUrls=$validRemoteUrls, webUrl=$webUrl]';

  /// Returns a new [GitRepository] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GitRepository? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      assert(() {
        for (final key in requiredKeys) {
          assert(json.containsKey(key), 'Required key "GitRepository[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GitRepository[$key]" has a null value in JSON.');
        }
        return true;
      }());

      return GitRepository(
        links: _ReferenceLinks.fromJson(json[r'_links']),
        defaultBranch: json[r'defaultBranch'] as String?,
        id: json[r'id'] as String?,
        isDisabled: json[r'isDisabled'] as bool?,
        isFork: json[r'isFork'] as bool?,
        name: json[r'name'] as String?,
        parentRepository: _GitRepositoryRef.fromJson(json[r'parentRepository']),
        project: _TeamProjectReference.fromJson(json[r'project']),
        remoteUrl: json[r'remoteUrl'] as String?,
        size: json[r'size'] as int?,
        sshUrl: json[r'sshUrl'] as String?,
        url: json[r'url'] as String?,
        validRemoteUrls:
            json[r'validRemoteUrls'] is List ? (json[r'validRemoteUrls'] as List).cast<String>() : const [],
        webUrl: json[r'webUrl'] as String?,
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

  static Map<String, GitRepository> mapFromJson(dynamic json) {
    final map = <String, GitRepository>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GitRepository.fromJson(entry.value);
        if (value != null) {
          map[entry.key.toString()] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GitRepository-objects as value to a dart map
  static Map<String, List<GitRepository>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GitRepository>>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GitRepository.listFromJson(
          entry.value,
          growable: growable,
        );
        if (value != null) {
          map[entry.key.toString()] = value;
        }
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}

class _GitRepositoryRef {
  /// Returns a new [_GitRepositoryRef] instance.
  _GitRepositoryRef({
    this.collection,
    this.id,
    this.isFork,
    this.name,
    this.project,
    this.remoteUrl,
    this.sshUrl,
    this.url,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  _TeamProjectCollectionReference? collection;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// True if the repository was created as a fork
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isFork;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  _TeamProjectReference? project;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? remoteUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sshUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GitRepositoryRef &&
          other.collection == collection &&
          other.id == id &&
          other.isFork == isFork &&
          other.name == name &&
          other.project == project &&
          other.remoteUrl == remoteUrl &&
          other.sshUrl == sshUrl &&
          other.url == url;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (collection == null ? 0 : collection!.hashCode) +
      (id == null ? 0 : id!.hashCode) +
      (isFork == null ? 0 : isFork!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (project == null ? 0 : project!.hashCode) +
      (remoteUrl == null ? 0 : remoteUrl!.hashCode) +
      (sshUrl == null ? 0 : sshUrl!.hashCode) +
      (url == null ? 0 : url!.hashCode);

  @override
  String toString() =>
      'GitRepositoryRef[collection=$collection, id=$id, isFork=$isFork, name=$name, project=$project, remoteUrl=$remoteUrl, sshUrl=$sshUrl, url=$url]';

  /// Returns a new [_GitRepositoryRef] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static _GitRepositoryRef? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        for (final key in requiredKeys) {
          assert(json.containsKey(key), 'Required key "GitRepositoryRef[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GitRepositoryRef[$key]" has a null value in JSON.');
        }
        return true;
      }());

      return _GitRepositoryRef(
        collection: _TeamProjectCollectionReference.fromJson(json[r'collection']),
        id: json[r'id'] as String?,
        isFork: json[r'isFork'] as bool?,
        name: json[r'name'] as String?,
        project: _TeamProjectReference.fromJson(json[r'project']),
        remoteUrl: json[r'remoteUrl'] as String?,
        sshUrl: json[r'sshUrl'] as String?,
        url: json[r'url'] as String?,
      );
    }
    return null;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}

class _TeamProjectCollectionReference {
  /// Returns a new [_TeamProjectCollectionReference] instance.
  _TeamProjectCollectionReference({
    this.id,
    this.name,
    this.url,
  });

  /// Collection Id.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Collection Name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// Collection REST Url.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TeamProjectCollectionReference && other.id == id && other.name == name && other.url == url;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) + (name == null ? 0 : name!.hashCode) + (url == null ? 0 : url!.hashCode);

  @override
  String toString() => 'TeamProjectCollectionReference[id=$id, name=$name, url=$url]';

  /// Returns a new [_TeamProjectCollectionReference] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static _TeamProjectCollectionReference? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        for (final key in requiredKeys) {
          assert(json.containsKey(key), 'Required key "TeamProjectCollectionReference[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TeamProjectCollectionReference[$key]" has a null value in JSON.');
        }
        return true;
      }());

      return _TeamProjectCollectionReference(
        id: json[r'id'] as String?,
        name: json[r'name'] as String?,
        url: json[r'url'] as String?,
      );
    }
    return null;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}

class _ReferenceLinks {
  /// Returns a new [_ReferenceLinks] instance.
  _ReferenceLinks({
    this.links = const {},
  });

  /// The readonly view of the links.  Because Reference links are readonly, we only want to expose them as read only.
  Map<String, Object> links;

  @override
  bool operator ==(Object other) => identical(this, other) || other is _ReferenceLinks && other.links == links;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (links.hashCode);

  @override
  String toString() => 'ReferenceLinks[links=$links]';

  /// Returns a new [_ReferenceLinks] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static _ReferenceLinks? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        for (final key in requiredKeys) {
          assert(json.containsKey(key), 'Required key "ReferenceLinks[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReferenceLinks[$key]" has a null value in JSON.');
        }
        return true;
      }());

      return _ReferenceLinks(
        links: json[r'links'] as Map<String, Object>? ?? const {},
      );
    }
    return null;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}

class _TeamProjectReference {
  /// Returns a new [_TeamProjectReference] instance.
  _TeamProjectReference({
    this.abbreviation,
    this.defaultTeamImageUrl,
    this.description,
    this.id,
    this.lastUpdateTime,
    this.name,
    this.revision,
    this.state,
    this.url,
    this.visibility,
  });

  /// Project abbreviation.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? abbreviation;

  /// Url to default team identity image.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? defaultTeamImageUrl;

  /// The project's description (if any).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// Project identifier.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Project last update time.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? lastUpdateTime;

  /// Project name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// Project revision.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? revision;

  /// Project state.
  _TeamProjectReferenceStateEnum? state;

  /// Url to the full version of the object.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? url;

  /// Project visibility.
  _TeamProjectReferenceVisibilityEnum? visibility;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TeamProjectReference &&
          other.abbreviation == abbreviation &&
          other.defaultTeamImageUrl == defaultTeamImageUrl &&
          other.description == description &&
          other.id == id &&
          other.lastUpdateTime == lastUpdateTime &&
          other.name == name &&
          other.revision == revision &&
          other.state == state &&
          other.url == url &&
          other.visibility == visibility;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (abbreviation == null ? 0 : abbreviation!.hashCode) +
      (defaultTeamImageUrl == null ? 0 : defaultTeamImageUrl!.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (id == null ? 0 : id!.hashCode) +
      (lastUpdateTime == null ? 0 : lastUpdateTime!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (revision == null ? 0 : revision!.hashCode) +
      (state == null ? 0 : state!.hashCode) +
      (url == null ? 0 : url!.hashCode) +
      (visibility == null ? 0 : visibility!.hashCode);

  @override
  String toString() =>
      'TeamProjectReference[abbreviation=$abbreviation, defaultTeamImageUrl=$defaultTeamImageUrl, description=$description, id=$id, lastUpdateTime=$lastUpdateTime, name=$name, revision=$revision, state=$state, url=$url, visibility=$visibility]';

  /// Returns a new [_TeamProjectReference] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static _TeamProjectReference? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        for (final key in requiredKeys) {
          assert(json.containsKey(key), 'Required key "TeamProjectReference[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TeamProjectReference[$key]" has a null value in JSON.');
        }
        return true;
      }());

      return _TeamProjectReference(
        abbreviation: json[r'abbreviation'] as String?,
        defaultTeamImageUrl: json[r'defaultTeamImageUrl'] as String?,
        description: json[r'description'] as String?,
        id: json[r'id'] as String,
        lastUpdateTime: DateTime.tryParse(json[r'lastUpdateTime'].toString())?.toLocal(),
        name: json[r'name'] as String,
        revision: json[r'revision'] as int?,
        state: _TeamProjectReferenceStateEnum.fromJson(json[r'state']),
        url: json[r'url'] as String?,
        visibility: _TeamProjectReferenceVisibilityEnum.fromJson(json[r'visibility']),
      );
    }
    return null;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}

/// Project state.
// ignore: use_enums
class _TeamProjectReferenceStateEnum {
  /// Instantiate a new enum with the provided [value].
  const _TeamProjectReferenceStateEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  static const deleting = _TeamProjectReferenceStateEnum._(r'deleting');
  static const new_ = _TeamProjectReferenceStateEnum._(r'new');
  static const wellFormed = _TeamProjectReferenceStateEnum._(r'wellFormed');
  static const createPending = _TeamProjectReferenceStateEnum._(r'createPending');
  static const all = _TeamProjectReferenceStateEnum._(r'all');
  static const unchanged = _TeamProjectReferenceStateEnum._(r'unchanged');
  static const deleted = _TeamProjectReferenceStateEnum._(r'deleted');

  static _TeamProjectReferenceStateEnum? fromJson(dynamic value) =>
      _TeamProjectReferenceStateEnumTypeTransformer().decode(value);
}

/// Transformation class that can [encode] an instance of [_TeamProjectReferenceStateEnum] to String,
/// and [decode] dynamic data back to [_TeamProjectReferenceStateEnum].
class _TeamProjectReferenceStateEnumTypeTransformer {
  factory _TeamProjectReferenceStateEnumTypeTransformer() =>
      _instance ??= const _TeamProjectReferenceStateEnumTypeTransformer._();

  const _TeamProjectReferenceStateEnumTypeTransformer._();

  String encode(_TeamProjectReferenceStateEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a TeamProjectReferenceStateEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  _TeamProjectReferenceStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'deleting':
          return _TeamProjectReferenceStateEnum.deleting;
        case r'new':
          return _TeamProjectReferenceStateEnum.new_;
        case r'wellFormed':
          return _TeamProjectReferenceStateEnum.wellFormed;
        case r'createPending':
          return _TeamProjectReferenceStateEnum.createPending;
        case r'all':
          return _TeamProjectReferenceStateEnum.all;
        case r'unchanged':
          return _TeamProjectReferenceStateEnum.unchanged;
        case r'deleted':
          return _TeamProjectReferenceStateEnum.deleted;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [_TeamProjectReferenceStateEnumTypeTransformer] instance.
  static _TeamProjectReferenceStateEnumTypeTransformer? _instance;
}

/// Project visibility.
// ignore: use_enums
class _TeamProjectReferenceVisibilityEnum {
  /// Instantiate a new enum with the provided [value].
  const _TeamProjectReferenceVisibilityEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  static const private = _TeamProjectReferenceVisibilityEnum._(r'private');
  static const public = _TeamProjectReferenceVisibilityEnum._(r'public');

  static _TeamProjectReferenceVisibilityEnum? fromJson(dynamic value) =>
      _TeamProjectReferenceVisibilityEnumTypeTransformer().decode(value);
}

/// Transformation class that can [encode] an instance of [_TeamProjectReferenceVisibilityEnum] to String,
/// and [decode] dynamic data back to [_TeamProjectReferenceVisibilityEnum].
class _TeamProjectReferenceVisibilityEnumTypeTransformer {
  factory _TeamProjectReferenceVisibilityEnumTypeTransformer() =>
      _instance ??= const _TeamProjectReferenceVisibilityEnumTypeTransformer._();

  const _TeamProjectReferenceVisibilityEnumTypeTransformer._();

  String encode(_TeamProjectReferenceVisibilityEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a TeamProjectReferenceVisibilityEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  _TeamProjectReferenceVisibilityEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'private':
          return _TeamProjectReferenceVisibilityEnum.private;
        case r'public':
          return _TeamProjectReferenceVisibilityEnum.public;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [_TeamProjectReferenceVisibilityEnumTypeTransformer] instance.
  static _TeamProjectReferenceVisibilityEnumTypeTransformer? _instance;
}
