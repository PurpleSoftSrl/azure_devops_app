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
        Text.rich(
          style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSecondary),
          TextSpan(
            children: [
              TextSpan(
                text: '''
This will create a few Azure DevOps service hook subscriptions for each category you select.
It has to be done only once for each project in the organization.

You must be part of the Project Administrators group to perform this action, or you can ask an administrator to give you the necessary permissions as documented ''',
              ),
              TextSpan(
                text: 'here.',
                style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchUrlString(
                        'https://learn.microsoft.com/en-us/azure/devops/service-hooks/view-permission?view=azure-devops',
                      ),
              ),
            ],
          ),
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

class _PageModeSwitch extends StatelessWidget {
  const _PageModeSwitch({
    required this.pageMode,
    required this.ctrl,
  });

  final _NotificationsSettingsController ctrl;
  final PageMode pageMode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton<String>(
        segments: PageMode.values
            .map(
              (mode) => ButtonSegment(
                value: mode.name,
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(mode.name.titleCase),
                ),
              ),
            )
            .toList(),
        selected: {pageMode.name},
        onSelectionChanged: ctrl.setPageMode,
        showSelectedIcon: false,
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(context.textTheme.bodyMedium),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? context.colorScheme.primary
                : Colors.white.withValues(alpha: .18),
          ),
          foregroundColor: WidgetStatePropertyAll(context.colorScheme.onPrimary),
          shape: WidgetStatePropertyAll(
            const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: Colors.white.withValues(alpha: .24))),
          animationDuration: Duration.zero,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
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
            onChanged: (value) => ctrl.toggleAllPushNotifications(project.id!, isEnabled: value),
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
          style: context.textTheme.titleSmall,
        ),
        if (subscriptionChildren.isEmpty)
          SwitchListTile(
            title: Text(
              'No subscriptions available',
              style: context.textTheme.bodySmall!.copyWith(color: context.colorScheme.onSecondary),
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
                style: context.textTheme.bodySmall!.copyWith(color: context.colorScheme.onSecondary),
                overflow: TextOverflow.ellipsis,
              ),
              value: ctrl.isPushNotificationsEnabled(project.id!, category, child),
              onChanged: (value) => ctrl.togglePushNotifications(project.id!, category, child, isEnabled: value),
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
          style: context.textTheme.titleSmall,
        ),
        ListTile(
          title: Text(
            'Create a subscription',
            style: context.textTheme.bodySmall!.copyWith(color: context.colorScheme.onSecondary),
          ),
          trailing: SizedBox(
            width: 80,
            height: 32,
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
