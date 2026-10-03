part of 'base_settings.dart';

class _SettingsController with ShareMixin, AppLogger {
  _SettingsController._(this.api, this.storage);

  final AzureApiService api;
  final StorageService storage;

  late String gitUsername = api.user!.emailAddress!;

  String appVersion = '';

  final directories = ValueNotifier<ApiResponse<List<UserTenant>>?>(null);

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    appVersion = info.version;

    final orgs = await api.getDirectories();
    // copyWith is needed to make page visible even if getDirectories returns 401
    directories.value = orgs.copyWith(isError: false, data: orgs.data ?? []);
  }

  void shareApp() {
    final appUrl = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=io.purplesoft.azuredevops'
        : 'https://apps.apple.com/app/apple-store/id1666994628?pt=120276127&ct=app&mt=8';

    shareUrl(appUrl);
  }

  Future<void> logout() async {
    final confirm = await OverlayService.confirm('Attention', description: 'Do you really want to logout?');
    if (!confirm) return;

    await api.logout();
    await MsalService().logout();

    // Rebuild app to reset dependencies. This is needed to fix user null error after logout and login
    rebuildApp();

    unawaited(AppRouter.goToLogin());
  }

  void goToChooseSubscription() {
    AppRouter.goToChooseSubscription();
  }

  void seeChosenProjects() {
    AppRouter.goToChooseProjects(removeRoutes: false);
  }

  Future<void> changeDefaultCollection() async {
    final profile = storage.getActiveConnectionProfile();
    if (profile == null || profile.isCloud) {
      OverlayService.error(
        'Azure DevOps Online connection',
        description: 'A collection can be changed only for a self-hosted Azure DevOps Server connection.',
      );
      return;
    }

    final collectionCtrl = TextEditingController(
      text: profile.collection ?? 'DefaultCollection',
    );
    await OverlayService.bottomsheet(
      title: 'Change default collection',
      isScrollControlled: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DevOpsFormField(
            label: 'Server URL',
            controller: TextEditingController(text: profile.serverUrl),
            enabled: false,
            onChanged: (_) {},
            validator: (_) => null,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          DevOpsFormField(
            label: 'Default collection',
            controller: collectionCtrl,
            onChanged: (_) {},
            maxLines: 1,
          ),
          const SizedBox(height: 24),
          LoadingButton(
            text: 'Save',
            onPressed: () {
              final collection = collectionCtrl.text.trim();
              if (collection.isEmpty) return;
              AzdoBaseUrlController.setServerConnection(
                serverUrl: profile.serverUrl,
                collection: collection,
              );
              AppRouter.popRoute();
              OverlayService.snackbar('Default collection updated');
            },
          ),
        ],
      ),
    );
  }

  void changeThemeMode(String mode) {
    PurpleTheme.of(AppRouter.rootNavigator!.context).changeTheme(mode);
    storage.setThemeMode(mode);
  }

  void clearLocalStorage() {
    storage.clearNoToken();

    OverlayService.snackbar('Cache cleared!');

    AppRouter.goToChooseProjects(removeRoutes: false);
  }

  Future<void> manageConnections() async {
    await OverlayService.bottomsheet(
      title: 'Azure DevOps Connections',
      isScrollControlled: true,
      heightPercentage: .85,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final profiles = storage.getConnectionProfiles();
          final activeId = storage.getActiveConnectionProfileId();
          return ListView(
            children: [
              for (final profile in profiles)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(profile.isCloud ? Icons.cloud_queue : Icons.dns_outlined),
                  title: Text(profile.name),
                  subtitle: Text(_profileSubtitle(profile)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (profile.id == activeId) const Icon(Icons.check_circle),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await _editConnection(profile);
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: profiles.length < 2
                            ? null
                            : () async {
                                await _deleteConnection(profile);
                                setState(() {});
                              },
                      ),
                    ],
                  ),
                  onTap: () async {
                    await _activateConnection(profile);
                    setState(() {});
                  },
                ),
              const SizedBox(height: 20),
              LoadingButton(
                text: 'Add connection',
                onPressed: () async {
                  await _editConnection(null);
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _profileSubtitle(AzureDevOpsConnectionProfile profile) {
    if (profile.isCloud) {
      return 'Azure DevOps Online - ${profile.organization ?? ''} - ${profile.authType.name}';
    }
    return 'Azure DevOps Server - ${profile.serverUrl} / ${profile.collection ?? ''}';
  }

  Future<void> _activateConnection(AzureDevOpsConnectionProfile profile) async {
    storage.setActiveConnectionProfileId(profile.id);
    storage.setOrganization(profile.isCloud ? (profile.organization ?? '') : (profile.collection ?? ''));
    api.switchOrganization(profile.scopeName);
    OverlayService.snackbar('Active connection: ${profile.name}');
    await AppRouter.goToChooseProjects(removeRoutes: false);
  }

  Future<void> _deleteConnection(AzureDevOpsConnectionProfile profile) async {
    final confirm = await OverlayService.confirm(
      'Delete connection',
      description: 'Delete ${profile.name}? Saved credentials for this connection will be removed.',
    );
    if (!confirm) return;

    final profiles = storage.getConnectionProfiles().where((p) => p.id != profile.id).toList();
    storage.deleteConnectionCredential(profile.id);
    storage.setConnectionProfiles(profiles);
    if (storage.getActiveConnectionProfileId() == profile.id && profiles.isNotEmpty) {
      storage.setActiveConnectionProfileId(profiles.first.id);
    }
  }

  Future<void> _editConnection(AzureDevOpsConnectionProfile? existing) async {
    var hostType = existing?.hostType ?? AzureDevOpsHostType.server;
    var authType = existing?.authType ?? AzureDevOpsAuthType.pat;
    final nameCtrl = TextEditingController(text: existing?.name ?? 'Codizen DevOps ORG');
    final serverCtrl = TextEditingController(text: existing?.serverUrl ?? 'https://devops.codizen.org');
    final orgCtrl = TextEditingController(text: existing?.organization ?? storage.getOrganization());
    final collectionCtrl = TextEditingController(text: existing?.collection ?? 'DefaultCollection');
    final apiVersionCtrl = TextEditingController(text: existing?.apiVersion ?? '7.0');
    final patCtrl = TextEditingController();
    var obscurePat = true;
    String? testMessage;

    await OverlayService.bottomsheet(
      title: existing == null ? 'Add connection' : 'Edit connection',
      isScrollControlled: true,
      heightPercentage: .9,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<AzureDevOpsHostType>(
                  segments: const [
                    ButtonSegment(value: AzureDevOpsHostType.cloud, label: Text('Azure DevOps Online')),
                    ButtonSegment(value: AzureDevOpsHostType.server, label: Text('Self-hosted Server')),
                  ],
                  selected: {hostType},
                  onSelectionChanged: (value) => setState(() => hostType = value.first),
                ),
                const SizedBox(height: 16),
                DevOpsFormField(label: 'Connection Name', controller: nameCtrl, maxLines: 1, onChanged: (_) {}),
                const SizedBox(height: 12),
                if (hostType == AzureDevOpsHostType.cloud) ...[
                  DevOpsFormField(label: 'Organization', controller: orgCtrl, maxLines: 1, onChanged: (_) {}),
                  const SizedBox(height: 12),
                  SegmentedButton<AzureDevOpsAuthType>(
                    segments: const [
                      ButtonSegment(value: AzureDevOpsAuthType.microsoft, label: Text('Microsoft Sign In')),
                      ButtonSegment(value: AzureDevOpsAuthType.pat, label: Text('Personal Access Token')),
                    ],
                    selected: {authType},
                    onSelectionChanged: (value) => setState(() => authType = value.first),
                  ),
                ] else ...[
                  DevOpsFormField(
                    label: 'Server URL',
                    controller: serverCtrl,
                    enabled: existing?.isServer != true,
                    maxLines: 1,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  DevOpsFormField(label: 'Collection', controller: collectionCtrl, maxLines: 1, onChanged: (_) {}),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          nameCtrl.text = 'Codizen DevOps ORG';
                          serverCtrl.text = 'https://devops.codizen.org';
                          collectionCtrl.text = 'DefaultCollection';
                        }),
                        child: const Text('Codizen .org'),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          nameCtrl.text = 'Codizen DevOps IR';
                          serverCtrl.text = 'https://devops.codizen.ir';
                          collectionCtrl.text = 'DefaultCollection';
                        }),
                        child: const Text('Codizen .ir'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                DevOpsFormField(label: 'API version', controller: apiVersionCtrl, maxLines: 1, onChanged: (_) {}),
                if (hostType == AzureDevOpsHostType.server || authType == AzureDevOpsAuthType.pat) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: patCtrl,
                    obscureText: obscurePat,
                    decoration: InputDecoration(
                      labelText: existing == null ? 'Personal Access Token' : 'Replace Personal Access Token',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePat ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscurePat = !obscurePat),
                      ),
                    ),
                  ),
                ],
                if (testMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(testMessage!),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: LoadingButton(
                        text: 'Test Connection',
                        onPressed: () async {
                          final profile = _profileFromFields(
                            existing,
                            hostType,
                            authType,
                            nameCtrl,
                            serverCtrl,
                            orgCtrl,
                            collectionCtrl,
                            apiVersionCtrl,
                          );
                          final credential = patCtrl.text.trim().isNotEmpty
                              ? patCtrl.text.trim()
                              : storage.getConnectionCredential(profile.id);
                          final result = await _testConnection(profile, credential);
                          setState(() => testMessage = result);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LoadingButton(
                        text: 'Save',
                        onPressed: () {
                          final profile = _profileFromFields(
                            existing,
                            hostType,
                            authType,
                            nameCtrl,
                            serverCtrl,
                            orgCtrl,
                            collectionCtrl,
                            apiVersionCtrl,
                          );
                          _saveConnection(profile, patCtrl.text.trim());
                          AppRouter.popRoute();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AzureDevOpsConnectionProfile _profileFromFields(
    AzureDevOpsConnectionProfile? existing,
    AzureDevOpsHostType hostType,
    AzureDevOpsAuthType authType,
    TextEditingController nameCtrl,
    TextEditingController serverCtrl,
    TextEditingController orgCtrl,
    TextEditingController collectionCtrl,
    TextEditingController apiVersionCtrl,
  ) {
    final id = existing?.id ?? 'azdo_${DateTime.now().microsecondsSinceEpoch}';
    if (hostType == AzureDevOpsHostType.cloud) {
      return AzureDevOpsConnectionProfile(
        id: id,
        name: nameCtrl.text.trim().isEmpty ? 'Azure DevOps Online' : nameCtrl.text.trim(),
        hostType: hostType,
        authType: authType,
        serverUrl: 'https://dev.azure.com',
        organization: orgCtrl.text.trim(),
        apiVersion: apiVersionCtrl.text.trim().isEmpty ? '7.0' : apiVersionCtrl.text.trim(),
        isDefault: existing?.isDefault ?? false,
      );
    }

    return AzureDevOpsConnectionProfile.server(
      id: id,
      name: nameCtrl.text.trim().isEmpty ? serverCtrl.text.trim() : nameCtrl.text.trim(),
      serverUrl: serverCtrl.text.trim(),
      collection: collectionCtrl.text.trim().isEmpty ? 'DefaultCollection' : collectionCtrl.text.trim(),
      apiVersion: apiVersionCtrl.text.trim().isEmpty ? '7.0' : apiVersionCtrl.text.trim(),
      isDefault: existing?.isDefault ?? false,
    );
  }

  void _saveConnection(AzureDevOpsConnectionProfile profile, String credential) {
    final profiles = storage.getConnectionProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index == -1) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }
    storage.setConnectionProfiles(profiles);
    if (credential.isNotEmpty) storage.setConnectionCredential(profile.id, credential);
    if (storage.getActiveConnectionProfileId().isEmpty) storage.setActiveConnectionProfileId(profile.id);
    OverlayService.snackbar('Connection saved');
  }

  Future<String> _testConnection(AzureDevOpsConnectionProfile profile, String credential) async {
    if (profile.authType == AzureDevOpsAuthType.pat && credential.isEmpty) {
      return 'Enter a Personal Access Token before testing.';
    }

    try {
      final resolver = AzureDevOpsEndpointResolver(profile);
      final uri = resolver.collectionApi('_apis/projects', {'api-version': resolver.apiVersion});
      final authHeaders = AzureDevOpsAuthHeaderProvider(connection: profile, accessToken: credential).getHeadersSync();
      final res = await http
          .get(uri, headers: {'Accept': 'application/json', ...authHeaders})
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return 'Connected successfully\nServer: ${uri.host}\nCollection: ${profile.scopeName}\nProjects found: ${body['count'] ?? 0}';
      }
      if (res.statusCode == 401) return 'Authentication failed. Check the Personal Access Token.';
      if (res.statusCode == 403) return 'Authenticated, but this token/user does not have permission.';
      if (res.statusCode == 404) return 'The server or collection could not be found.';
      if (res.headers['content-type']?.contains('text/html') ?? false) {
        return 'The endpoint returned HTML. IIS, a reverse proxy, or login routing may be intercepting REST API requests.';
      }
      return 'Connection failed with HTTP ${res.statusCode}.';
    } on FormatException {
      return 'Invalid server URL or non-JSON REST response.';
    } on HandshakeException {
      return 'TLS/certificate validation failed. Check the server certificate.';
    } on TimeoutException {
      return 'Connection timed out. Check host/network access.';
    } on SocketException catch (e) {
      return 'Network failure: ${e.message}';
    } catch (e) {
      return redactCredentialText('Connection failed: $e');
    }
  }

  void openPurplesoftWebsite(FollowLink? link) {
    logInfo('Open Purplesoft website');

    link?.call();
  }

  void openAppStore() {
    InAppReview.instance.openStoreListing(appStoreId: '1666994628');
  }

  Future<void> chooseDirectory() async {
    await OverlayService.bottomsheet(
      title: 'Switch directory',
      isScrollControlled: true,
      heightPercentage: .6,
      builder: (context) =>
          _SwitchDirectoryWidget(directories: directories.value?.data ?? [], onSwitch: _switchOrganization),
    );
  }

  Future<void> _switchOrganization(UserTenant tenant) async {
    try {
      // Logout to avoid cached account errors
      await MsalService().logout();
    } catch (e) {
      // ignore
    }

    final loginRes = await MsalService().login(authority: 'https://login.microsoftonline.com/${tenant.id}');

    if (loginRes != null) unawaited(_loginAndNavigate(loginRes));
  }

  Future<void> chooseAccount() async {
    try {
      // Logout to avoid cached account errors
      await MsalService().logout();
    } catch (e) {
      // ignore
    }

    final loginRes = await MsalService().login();

    if (loginRes != null) unawaited(_loginAndNavigate(loginRes));
  }

  Future<void> _loginAndNavigate(LoginResponse loginResponse) async {
    storage
      ..setOrganization('')
      ..setTenantId(loginResponse.tenantId);

    final isLogged = await api.login(loginResponse.accessToken);

    final isFailed = [LoginStatus.failed, LoginStatus.unauthorized].contains(isLogged);

    logAnalytics('switch_directory_${isFailed ? 'failed' : 'success'}', {});

    if (isLogged == LoginStatus.failed) {
      return _switchDirectoryErrorAlert();
    }

    final orgsRes = await api.getOrganizations();

    if (orgsRes.data?.isEmpty ?? true) {
      return _switchDirectoryErrorAlert();
    }

    final directoryProjects = storage.getTenantChosenProjects(loginResponse.tenantId);

    if (directoryProjects.isNotEmpty) {
      await _chooseOrg(orgsRes.data!);
      storage.setChosenProjects(directoryProjects);
      return AppRouter.goToTabs();
    }

    await AppRouter.goToChooseProjects();
  }

  Future<void> _switchDirectoryErrorAlert() {
    return OverlayService.error(
      'Error switching directory',
      description:
          'Check that you have access to this organization and that the organization has at least one project.',
    );
  }

  Future<void> _chooseOrg(List<Organization> orgs) async {
    if (orgs.length < 2) {
      await api.setOrganization(orgs.first.accountName!);
      return;
    }

    final selectedOrg = await _selectOrganization(orgs);
    if (selectedOrg == null) return;

    await api.setOrganization(selectedOrg.accountName!);
  }

  Future<Organization?> _selectOrganization(List<Organization> orgs) async {
    Organization? selectedOrg;

    await OverlayService.bottomsheet(
      isDismissible: false,
      title: 'Select your organization',
      isScrollControlled: true,
      heightPercentage: .7,
      builder: (context) => ListView(
        children: [
          ...orgs.map(
            (u) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: LoadingButton(
                onPressed: () {
                  selectedOrg = u;
                  AppRouter.popRoute();
                },
                text: u.accountName!,
              ),
            ),
          ),
        ],
      ),
    );
    return selectedOrg;
  }

  Future<void> showChangelog() async {
    final str = await rootBundle.loadString('CHANGELOG.md');

    await OverlayService.bottomsheet(
      title: 'CHANGELOG',
      isScrollControlled: true,
      heightPercentage: .9,
      builder: (context) => SingleChildScrollView(
        child: AppMarkdownWidget(
          data: str,
          shrinkWrap: false,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(p: context.textTheme.titleSmall),
          paddingBuilders: {'h2': _H2PaddingBuilder()},
        ),
      ),
    );
  }

  void openPrivacyPolicy() {
    launchUrlString('https://www.iubenda.com/privacy-policy/92670429/legal');
  }

  void openTermsAndConditions() {
    launchUrlString('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
  }
}

class _H2PaddingBuilder extends MarkdownPaddingBuilder {
  @override
  EdgeInsets getPadding() => const EdgeInsets.only(top: 16);
}
