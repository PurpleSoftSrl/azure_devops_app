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
          icon: Icon(Icons.info_outline),
        ),
      ],
      builder: (subscriptions) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose the categories of push notifications you want to subscribe to for each project.',
            style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
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
                  children: ctrl.eventCategories.entries
                      .map(
                        (entry) => ctrl.hasHookSubscription(p.id!, entry.key)
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
                      )
                      .toList(),
                ),
                if (p != ctrl.projects.last) const Divider(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
