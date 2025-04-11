part of notifications_settings;

class _InfoBottomsheet extends StatelessWidget {
  const _InfoBottomsheet({required this.eventCategories});

  final Map<EventCategory, List<EventType>> eventCategories;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        Text("1. Tap on 'Create' button", style: context.textTheme.bodyMedium),
        Text(
          'This will create a few Azure DevOps service hooks for each category you select.\nIt has to be done only once for each project in the organization.',
          style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSecondary),
        ),
        const SizedBox(height: 12),
        Text('2. Switch on the toggle for the items you are interested in', style: context.textTheme.bodyMedium),
        Text(
          'This will subscribe you to push notifications for the selected repository/pipeline/area.\nIt has to be done on each device you want to receive notifications on.',
          style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSecondary),
        ),
        const SizedBox(height: 12),
        Text('3. Trigger one of these events to receive a push notification', style: context.textTheme.bodyMedium),
        ...eventCategories.entries.map(
          (entry) => ListTile(
            title: Text(
              '- ${entry.key.description}',
              style: context.textTheme.labelLarge,
            ),
            subtitle: Text(
              entry.value.map((e) => e.description).join(', '),
              style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSecondary),
            ),
            contentPadding: EdgeInsets.zero,
            minTileHeight: 20,
          ),
        ),
      ],
    );
  }
}

class _ProjectTitleRow extends StatelessWidget {
  const _ProjectTitleRow({
    required this.ctrl,
    required this.project,
  });

  final _NotificationsSettingsController ctrl;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            project.name!,
            style: context.textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (ctrl.hasAllHookSubscriptions(project.id!))
          Switch(
            value: ctrl.isAllPushNotificationsEnabled(project.id!),
            onChanged: (value) => ctrl.toggleAllPushNotifications(project.id!, value: value),
          )
        else
          const SizedBox(height: 48),
      ],
    );
  }
}

class _ActiveSubscription extends StatelessWidget {
  const _ActiveSubscription({
    required this.ctrl,
    required this.project,
    required this.category,
  });

  final _NotificationsSettingsController ctrl;
  final Project project;
  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    final subscriptionChildren = ctrl.getCachedSubscriptionChildren(project.id!, category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          category.description,
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
              value: ctrl.isPushNotificationsEnabled(project.id!, category, child),
              onChanged: (value) => ctrl.togglePushNotifications(project.id!, category, child, value: value),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}

class _InactiveSubscription extends StatelessWidget {
  const _InactiveSubscription({
    required this.ctrl,
    required this.project,
    required this.category,
  });

  final _NotificationsSettingsController ctrl;
  final Project project;
  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          category.description,
          style: context.textTheme.bodyMedium,
        ),
        ListTile(
          title: Text(
            'Create a subscription',
            style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSecondary),
          ),
          trailing: SizedBox(
            width: 80,
            height: 48,
            child: LoadingButton(
              onPressed: () => ctrl.createHookSubscription(project.id!, category),
              margin: EdgeInsets.zero,
              text: 'Create',
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
