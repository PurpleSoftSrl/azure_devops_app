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
      builder: (subscriptions) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...ctrl.projects.map(
            (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        p.name!,
                        style: context.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (ctrl.hasAllHookSubscriptions(p.id!))
                      Switch(
                        value: ctrl.isAllPushNotificationsEnabled(p.id!),
                        onChanged: (value) => ctrl.toggleAllPushNotifications(p.id!, value: value),
                      )
                    else
                      const SizedBox(height: 48),
                  ],
                ),
                ...ctrl.eventCategories.entries.map(
                  (entry) {
                    if (ctrl.hasHookSubscription(p.id!, entry.key)) {
                      final subscriptionChildren = ctrl.getCachedSubscriptionChildren(p.id!, entry);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            entry.key.description,
                            style: context.textTheme.bodyMedium,
                          ),
                          if (subscriptionChildren.isEmpty)
                            SwitchListTile(
                              title: Text(
                                'No subscriptions available',
                                style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSecondary),
                              ),
                              value: false,
                              onChanged: null,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            )
                          else
                            ...subscriptionChildren.map(
                              (child) => SwitchListTile(
                                title: Text(
                                  child,
                                  style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                value: ctrl.isPushNotificationsEnabled(p.id!, entry.key, child),
                                onChanged: (value) =>
                                    ctrl.togglePushNotifications(p.id!, entry.key, child, value: value),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                      );
                    }

                    return ListTile(
                      title: Text(entry.key.description, style: context.textTheme.labelLarge),
                      subtitle: Text('Create a subscription', style: context.textTheme.labelSmall),
                      trailing: SizedBox(
                        width: 80,
                        height: 40,
                        child: LoadingButton(
                          onPressed: () => ctrl.createHookSubscription(p.id!, entry.key),
                          margin: EdgeInsets.zero,
                          text: 'Create',
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
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
