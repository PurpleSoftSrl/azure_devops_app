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
      notifier: ctrl.data,
      builder: (subscriptions) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...ctrl.projects.map(
            (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name!,
                  style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                ...EventType.values.where((t) => t != EventType.unknown).map(
                      (type) => ctrl.hasHookSubscription(p.id!, type)
                          ? SwitchListTile(
                              title: Text(type.description, style: context.textTheme.labelLarge),
                              subtitle: Text('Enable push notifications', style: context.textTheme.labelSmall),
                              value: ctrl.isPushNotificationsEnabled(p.id!, type),
                              onChanged: (value) => ctrl.togglePushNotifications(p.id!, type, value: value),
                              contentPadding: EdgeInsets.zero,
                            )
                          : ListTile(
                              title: Text(type.description, style: context.textTheme.labelLarge),
                              subtitle: Text('Create a subscription', style: context.textTheme.labelSmall),
                              trailing: SizedBox(
                                width: 80,
                                height: 40,
                                child: LoadingButton(
                                  onPressed: () => ctrl.createHookSubscription(p.id!, type),
                                  margin: EdgeInsets.zero,
                                  text: 'Create',
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
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
