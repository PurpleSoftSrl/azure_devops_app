part of settings;

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen(this.ctrl, this.parameters);

  final _SettingsController ctrl;
  final _SettingsParameters parameters;

  @override
  Widget build(BuildContext context) {
    final transparentBorder = OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent));
    return AppPage(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Settings',
      actions: [
        IconButton(
          onPressed: ctrl.shareApp,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            text: 'Personal info',
          ),
          Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Git username',
                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(ctrl.gitUsername),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Personal Access Token',
                      style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: ctrl.isEditing,
                      builder: (_, isEditing, __) => IconButton(
                        onPressed: ctrl.toggleIsEditingToken,
                        iconSize: 15,
                        padding: EdgeInsets.zero,
                        icon: Icon(isEditing ? Icons.check_circle_outline : Icons.edit),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: ctrl.isEditing,
                    builder: (_, isEditing, __) => TextFormField(
                      decoration: InputDecoration(
                        border: transparentBorder,
                        enabledBorder: transparentBorder,
                        focusedBorder: transparentBorder,
                        contentPadding: EdgeInsets.zero,
                      ),
                      controller: ctrl.patTextFieldController,
                      onFieldSubmitted: ctrl.setNewToken,
                      readOnly: !isEditing,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(
            text: 'App management',
          ),
          InkWell(
            onTap: ctrl.seeChosenProjects,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Icon(DevOpsIcons.list),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Manage projects',
                      style: context.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          ),
          SectionHeader(
            text: 'Theme',
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
              child: Row(
                children: [
                  _ThemeModeRadio(
                    mode: 'System',
                    onChanged: ctrl.changeThemeMode,
                    icon: DevOpsIcons.phone,
                  ),
                  _ThemeModeRadio(
                    mode: 'Dark',
                    onChanged: ctrl.changeThemeMode,
                    icon: DevOpsIcons.moon_star,
                  ),
                  _ThemeModeRadio(
                    mode: 'Light',
                    onChanged: ctrl.changeThemeMode,
                    icon: DevOpsIcons.sun,
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(
            text: 'Developer',
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Link(
                uri: Uri.parse('https://github.com/PurpleSoftSrl/azure_devops_app'),
                builder: (_, link) => InkWell(
                  onTap: link,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('GitHub repository'),
                      Icon(DevOpsIcons.github_mark),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Link(
                uri: Uri.parse(
                  'https://www.purplesoft.io?utm_source=azdevops_app&utm_medium=app&utm_campaign=azdevops',
                ),
                builder: (_, link) => InkWell(
                  onTap: () => ctrl.openPurplesoftWebsite(link),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Made with \u2764 by Purplesoft Srl'),
                      Icon(DevOpsIcons.link),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: ctrl.openAppStore,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Leave a review'),
                    Icon(Icons.rate_review_outlined),
                  ],
                ),
              ),
            ),
          ),
          SectionHeader(
            text: 'App settings',
          ),
          InkWell(
            onTap: ctrl.logout,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Logout'),
                    Icon(DevOpsIcons.logout),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: ctrl.clearLocalStorage,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Clear cache'),
                    Icon(Icons.cleaning_services),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          ValueListenableBuilder<String>(
            valueListenable: ctrl.appVersion,
            builder: (_, version, __) => Text(
              'Version $version',
              style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
