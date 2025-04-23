part of notifications_settings;

class _NotificationsSettingsScreen extends StatelessWidget {
  const _NotificationsSettingsScreen(this.ctrl, this.parameters);

  final _NotificationsSettingsController ctrl;
  final _NotificationsSettingsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      init: ctrl.init,
      title: 'Notifications',
      notifier: ctrl.subscriptions,
      actions: [
        IconButton(
          onPressed: ctrl.showInfo,
          icon: Icon(DevOpsIcons.info),
        ),
      ],
      builder: (subscriptions) => ValueListenableBuilder(
        valueListenable: ctrl.pageMode,
        builder: (_, pageMode, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Switch to admin mode to create the webhook subscriptions if they don't exist yet. Tap on the info icon for more details.",
              style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 24,
            ),
            _PageModeSwitch(
              ctrl: ctrl,
              pageMode: pageMode,
            ),
            const SizedBox(
              height: 24,
            ),
            ...ctrl.projects.map(
              (p) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpansionTile(
                    title: _ProjectTitleRow(
                      ctrl: ctrl,
                      project: p,
                    ),
                    tilePadding: EdgeInsets.zero,
                    shape: const Border(),
                    children: [
                      ...ctrl.eventCategories.entries.map(
                        (entry) => pageMode == PageMode.user || ctrl.hasHookSubscription(p.id!, entry.key)
                            ? _ActiveSubscription(
                                ctrl: ctrl,
                                project: p,
                                category: entry.key,
                              )
                            : _InactiveSubscription(
                                ctrl: ctrl,
                                project: p,
                                category: entry.key,
                              ),
                      ),
                      if (p != ctrl.projects.last) const Divider(height: 48),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
