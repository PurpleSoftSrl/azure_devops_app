import 'dart:convert';

enum AzureDevOpsHostType { cloud, server }

enum AzureDevOpsAuthType { microsoft, pat }

class AzureDevOpsConnectionProfile {
  AzureDevOpsConnectionProfile({
    required this.id,
    required this.name,
    required this.hostType,
    required this.authType,
    required this.serverUrl,
    this.organization,
    this.collection,
    this.apiVersion,
    this.isDefault = false,
  });

  factory AzureDevOpsConnectionProfile.cloud({
    required String id,
    required String organization,
    AzureDevOpsAuthType authType = AzureDevOpsAuthType.microsoft,
    bool isDefault = true,
  }) {
    return AzureDevOpsConnectionProfile(
      id: id,
      name: 'Azure DevOps Online',
      hostType: AzureDevOpsHostType.cloud,
      authType: authType,
      serverUrl: 'https://dev.azure.com',
      organization: organization,
      apiVersion: '7.0',
      isDefault: isDefault,
    );
  }

  factory AzureDevOpsConnectionProfile.server({
    required String id,
    required String name,
    required String serverUrl,
    required String collection,
    String apiVersion = '7.0',
    bool isDefault = false,
  }) {
    return AzureDevOpsConnectionProfile(
      id: id,
      name: name,
      hostType: AzureDevOpsHostType.server,
      authType: AzureDevOpsAuthType.pat,
      serverUrl: serverUrl,
      collection: collection,
      apiVersion: apiVersion,
      isDefault: isDefault,
    );
  }

  factory AzureDevOpsConnectionProfile.fromMap(Map<String, dynamic> map) {
    return AzureDevOpsConnectionProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      hostType: AzureDevOpsHostType.values.byName(map['hostType'] as String),
      authType: AzureDevOpsAuthType.values.byName(map['authType'] as String),
      serverUrl: map['serverUrl'] as String,
      organization: map['organization'] as String?,
      collection: map['collection'] as String?,
      apiVersion: map['apiVersion'] as String?,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  factory AzureDevOpsConnectionProfile.fromJson(String source) =>
      AzureDevOpsConnectionProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);

  final String id;
  final String name;
  final AzureDevOpsHostType hostType;
  final AzureDevOpsAuthType authType;
  final String serverUrl;
  final String? organization;
  final String? collection;
  final String? apiVersion;
  final bool isDefault;

  bool get isCloud => hostType == AzureDevOpsHostType.cloud;
  bool get isServer => hostType == AzureDevOpsHostType.server;

  String get scopeName => isCloud ? (organization ?? '') : (collection ?? '');

  AzureDevOpsConnectionProfile copyWith({
    String? id,
    String? name,
    AzureDevOpsHostType? hostType,
    AzureDevOpsAuthType? authType,
    String? serverUrl,
    String? organization,
    String? collection,
    String? apiVersion,
    bool? isDefault,
  }) {
    return AzureDevOpsConnectionProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      hostType: hostType ?? this.hostType,
      authType: authType ?? this.authType,
      serverUrl: serverUrl ?? this.serverUrl,
      organization: organization ?? this.organization,
      collection: collection ?? this.collection,
      apiVersion: apiVersion ?? this.apiVersion,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hostType': hostType.name,
      'authType': authType.name,
      'serverUrl': serverUrl,
      'organization': organization,
      'collection': collection,
      'apiVersion': apiVersion,
      'isDefault': isDefault,
    };
  }

  String toJson() => jsonEncode(toMap());
}
