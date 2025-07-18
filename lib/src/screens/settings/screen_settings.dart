part of settings;

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen(this.ctrl, this.parameters);

  final _SettingsController ctrl;
  final _SettingsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      init: ctrl.init,
      title: 'Settings',
      notifier: ctrl.directories,
      actions: [
        IconButton(
          onPressed: ctrl.shareApp,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      builder: (directories) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader.noMargin(
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
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: context.purchase.entitlementName,
            builder: (_, entitlementName, __) => entitlementName.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Current plan',
                        style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(entitlementName),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          SectionHeader(
            text: 'App management',
          ),
          NavigationButton(
            onTap: ctrl.goToChooseSubscription,
            child: Row(
              children: [
                Icon(DevOpsIcons.crown),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  'Choose plan',
                  style: context.textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          NavigationButton(
            onTap: ctrl.seeChosenProjects,
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
          if (directories.length > 1) ...[
            const SizedBox(
              height: 20,
            ),
            NavigationButton(
              onTap: ctrl.chooseDirectory,
              child: Row(
                children: [
                  Icon(DevOpsIcons.repository),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Switch directory',
                    style: context.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
          ],
          SectionHeader(
            text: 'Theme',
          ),
          NavigationButton(
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
          SectionHeader(
            text: 'Developer',
          ),
          NavigationButton(
            child: Link(
              uri: Uri.parse('https://github.com/PurpleSoftSrl/azure_devops_app'),
              builder: (_, link) => InkWell(
                onTap: link,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('GitHub repository'),
                    Icon(DevOpsIcons.github),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          NavigationButton(
            child: Link(
              uri: Uri.parse(
                'https://www.purplesoft.io?utm_source=azdevops_app&utm_medium=app&utm_campaign=azdevops',
              ),
              builder: (_, link) => InkWell(
                onTap: () => ctrl.openPurplesoftWebsite(link),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Made with \u2764 by PurpleSoft Srl'),
                    Icon(DevOpsIcons.link),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          NavigationButton(
            onTap: ctrl.openAppStore,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Leave a review'),
                Icon(Icons.rate_review_outlined),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          NavigationButton(
            onTap: ctrl.showChangelog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Changelog'),
                Icon(Icons.history),
              ],
            ),
          ),
          SectionHeader(
            text: 'App settings',
          ),
          NavigationButton(
            onTap: ctrl.logout,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Logout'),
                Icon(DevOpsIcons.logout),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          NavigationButton(
            onTap: ctrl.clearLocalStorage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Clear cache'),
                Icon(Icons.cleaning_services),
              ],
            ),
          ),
          SectionHeader(
            text: 'Policies',
          ),
          NavigationButton(
            onTap: ctrl.openPrivacyPolicy,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Privacy policy'),
                Icon(DevOpsIcons.link),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          NavigationButton(
            onTap: ctrl.openTermsAndConditions,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Terms and Use'),
                Icon(DevOpsIcons.link),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            'Version ${ctrl.appVersion}',
            style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }
}
