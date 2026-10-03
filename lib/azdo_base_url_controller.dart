import 'package:azure_devops/src/models/azure_devops_connection.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class AzdoBaseUrlController {
  static StorageService get storage => StorageServiceCore.instance!;

  static final ValueNotifier<String?> baseUrlNotifier = ValueNotifier<String?>(
    storage.getBaseUrl(),
  );

  static final ValueNotifier<bool> isSignedInNotifier = ValueNotifier<bool>(
    storage.getToken().isNotEmpty,
  );

  static String get baseUrl =>
      baseUrlNotifier.value ?? 'https://dev.azure.com/';

  static String get usersBasePath =>
      baseUrlNotifier.value ?? 'https://vssps.dev.azure.com/';

  static void set(String value) {
    final cleaned = value.trim();
    storage.setBaseUrl(cleaned);
    _syncActiveConnection(cleaned);
    baseUrlNotifier.value = cleaned;
  }

  static String get collection =>
      storage.getActiveConnectionProfile()?.collection ?? 'DefaultCollection';

  static void setServerConnection({
    required String serverUrl,
    required String collection,
  }) {
    final cleaned = serverUrl.trim();
    if (cleaned.isEmpty) {
      clear();
      return;
    }

    final parsed = Uri.parse(cleaned);
    final normalizedServer = parsed
        .replace(path: '', query: null, fragment: null)
        .toString()
        .replaceFirst(RegExp(r'/$'), '');
    final normalizedCollection = collection.trim().isEmpty
        ? 'DefaultCollection'
        : collection.trim();
    storage.setBaseUrl(normalizedServer);
    _syncActiveConnection(
      normalizedServer,
      collection: normalizedCollection,
    );
    baseUrlNotifier.value = normalizedServer;
  }

  static void clear() => set('');

  static void refreshFromStorage() {
    baseUrlNotifier.value = storage.getBaseUrl();
  }

  static void markSignedIn() => isSignedInNotifier.value = true;

  static void markSignedOut() => isSignedInNotifier.value = false;

  static bool isCustomUrl() {
    return baseUrlNotifier.value != null;
  }

  static String get loginpath {
    return isCustomUrl() ? '_apis/connectionData' : '_apis/profile/profiles/me';
  }

  static void _syncActiveConnection(String value, {String? collection}) {
    final existing =
        storage.getActiveConnectionProfile() ??
        storage.ensureDefaultConnectionProfile(
          authType: AzureDevOpsAuthType.pat,
        );
    final profiles = storage.getConnectionProfiles();
    final index = profiles.indexWhere((p) => p.id == existing.id);

    final profile = value.isEmpty
        ? _cloudProfile(existing)
        : _serverProfile(existing, value, collection: collection);
    if (index == -1) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }

    storage
      ..setConnectionProfiles(profiles)
      ..setActiveConnectionProfileId(profile.id)
      ..setOrganization(profile.scopeName);
  }

  static AzureDevOpsConnectionProfile _cloudProfile(
    AzureDevOpsConnectionProfile existing,
  ) {
    return AzureDevOpsConnectionProfile.cloud(
      id: existing.id,
      organization: existing.organization ?? storage.getOrganization(),
      authType: existing.authType,
    );
  }

  static AzureDevOpsConnectionProfile _serverProfile(
    AzureDevOpsConnectionProfile existing,
    String value, {
    String? collection,
  }) {
    final parsed = Uri.parse(value);
    final serverUri = parsed.hasScheme
        ? parsed.replace(path: '', query: null, fragment: null)
        : Uri.parse(
            'https://$value',
          ).replace(path: '', query: null, fragment: null);
    final resolvedCollection = collection ??
        (parsed.pathSegments.isEmpty
            ? 'DefaultCollection'
            : parsed.pathSegments.first);
    return AzureDevOpsConnectionProfile.server(
      id: existing.id,
      name: existing.name.isEmpty ? serverUri.host : existing.name,
      serverUrl: serverUri.toString().replaceFirst(RegExp(r'/$'), ''),
      collection: resolvedCollection,
      apiVersion: existing.apiVersion ?? '7.0',
    );
  }
}
