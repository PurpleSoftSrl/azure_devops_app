part of work_item_detail;

class _WorkItemDetailScreen extends StatelessWidget {
  const _WorkItemDetailScreen(this.ctrl, this.parameters);

  final _WorkItemDetailController ctrl;
  final _WorkItemDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    final item = ctrl.item;
    return AppPage<WorkItemDetail?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: '${item.workItemType} ${item.id}',
      notifier: ctrl.itemDetail,
      onEmpty: (_) => Text('No work item found'),
      actions: [
        PopupMenuButton<void>(
          key: ValueKey('Popup menu work item detail'),
          itemBuilder: (_) => [
            PopupMenuItem<void>(
              onTap: ctrl.shareWorkItem,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share',
                    style: context.textTheme.titleSmall,
                  ),
                  Icon(DevOpsIcons.share),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<void>(
              onTap: ctrl.editWorkItem,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit',
                    style: context.textTheme.titleSmall,
                  ),
                  Icon(DevOpsIcons.edit),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<void>(
              onTap: ctrl.deleteWorkItem,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delete',
                    style: context.textTheme.titleSmall,
                  ),
                  Icon(DevOpsIcons.failed),
                ],
              ),
            ),
          ],
          elevation: 0,
          tooltip: 'Work item actions',
          offset: const Offset(0, 40),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          child: Icon(DevOpsIcons.dots_horizontal),
        ),
        const SizedBox(
          width: 8,
        ),
      ],
      builder: (detail) => DefaultTextStyle(
        style: context.textTheme.titleSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                WorkItem(
                  assignedTo: null,
                  id: -1,
                  workItemType: detail!.fields.systemWorkItemType,
                  title: '',
                  state: '',
                  changedDate: DateTime.now(),
                  teamProject: '',
                  activityDate: DateTime.now(),
                  activityType: '',
                  identityId: '',
                ).workItemTypeIcon,
                const SizedBox(
                  width: 20,
                ),
                Text(detail.fields.systemWorkItemType),
                const SizedBox(
                  width: 10,
                ),
                Text(detail.id.toString()),
                const Spacer(),
                const SizedBox(
                  width: 10,
                ),
                Text(detail.fields.systemState),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  'Created by: ',
                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                ),
                Text(detail.fields.systemCreatedBy.displayName),
                if (ctrl.apiService.organization.isNotEmpty) ...[
                  const SizedBox(
                    width: 10,
                  ),
                  MemberAvatar(
                    userDescriptor: detail.fields.systemCreatedBy.descriptor,
                    radius: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                const Spacer(),
                Text(detail.fields.systemCreatedDate.minutesAgo),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ProjectChip(
              onTap: ctrl.goToProject,
              projectName: detail.fields.systemTeamProject,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Title:',
              style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
            ),
            Text(detail.fields.systemTitle),
            if (detail.fields.systemDescription != null) ...[
              const SizedBox(
                height: 20,
              ),
              Text(
                'Description:',
                style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
              ),
              Html(
                data: detail.fields.systemDescription!,
                onLinkTap: (str, _, __, ___) async {
                  final url = str.toString();
                  if (await canLaunchUrlString(url)) await launchUrlString(url);
                },
                customRenders: {
                  (ctx) => ctx.tree.element?.localName == 'img': CustomRender.widget(
                    widget: (ctx, child) => Image.network(
                      ctx.tree.attributes['src']!,
                      headers: ctrl.apiService.headers,
                      fit: BoxFit.contain,
                      height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
                      width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                          frame == null ? Center(child: const CircularProgressIndicator()) : child,
                    ),
                  ),
                  (ctx) => ctx.tree.element?.localName == 'br': CustomRender.widget(
                    widget: (ctx, child) => const Text('\n'),
                  ),
                },
              ),
            ],
            if (detail.fields.reproSteps != null) ...[
              const SizedBox(
                height: 20,
              ),
              Text(
                'Repro Steps:',
                style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
              ),
              Html(
                data: detail.fields.reproSteps!,
                onLinkTap: (str, _, __, ___) async {
                  final url = str.toString();
                  if (await canLaunchUrlString(url)) await launchUrlString(url);
                },
                customRenders: {
                  (ctx) => ctx.tree.element?.localName == 'img': CustomRender.widget(
                    widget: (ctx, child) => Image.network(
                      ctx.tree.attributes['src']!,
                      headers: ctrl.apiService.headers,
                      fit: BoxFit.contain,
                      height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
                      width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                          frame == null ? Center(child: const CircularProgressIndicator()) : child,
                    ),
                  ),
                  (ctx) => ctx.tree.element?.localName == 'br': CustomRender.widget(
                    widget: (ctx, child) => const Text('\n'),
                  ),
                },
              ),
            ],
            const Divider(
              height: 40,
            ),
            if (detail.fields.systemAssignedTo != null)
              Row(
                children: [
                  TextTitleDescription(
                    title: 'Assigned to: ',
                    description: detail.fields.systemAssignedTo!.displayName,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  MemberAvatar(
                    userDescriptor: detail.fields.systemAssignedTo!.descriptor,
                  ),
                ],
              ),
            const SizedBox(
              height: 20,
            ),
            TextTitleDescription(
              title: 'Created at: ',
              description: detail.fields.systemCreatedDate.toSimpleDate(),
            ),
            const SizedBox(
              height: 10,
            ),
            TextTitleDescription(
              title: 'Change date: ',
              description: detail.fields.systemChangedDate.toSimpleDate(),
            ),
            const SizedBox(
              height: 40,
            ),
            SectionHeader.noMargin(text: 'History'),
            Column(
              children: ctrl.updates.reversed.where((u) => u.hasSUpportedChanges).map(
                (update) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    MemberAvatar(userDescriptor: update.revisedBy.descriptor, radius: 15),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(update.revisedBy.displayName),
                                    const Spacer(),
                                    if (update.fields.systemChangedDate?.newValue != null)
                                      Text(DateTime.tryParse(update.fields.systemChangedDate!.newValue!)!.minutesAgo),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                DefaultTextStyle(
                                  style: context.textTheme.labelSmall!.copyWith(
                                    fontFamily: AppTheme.defaultFont,
                                    fontWeight: FontWeight.w200,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (update == ctrl.updates.first)
                                        Text(
                                          'Created work item',
                                        ),
                                      if (update.fields.systemWorkItemType?.newValue != null)
                                        Text(
                                          update.fields.systemWorkItemType?.oldValue == null
                                              ? 'Set type to ${update.fields.systemWorkItemType?.newValue}'
                                              : 'Changed type to ${update.fields.systemWorkItemType?.newValue}',
                                        ),
                                      if (update != ctrl.updates.first && update.fields.systemState?.newValue != null)
                                        Text(
                                          update.fields.systemState?.oldValue == null
                                              ? 'Set state to ${update.fields.systemState?.newValue}'
                                              : 'Changed state to ${update.fields.systemState?.newValue}',
                                        ),
                                      if (update.fields.systemAssignedTo?.newValue?.displayName != null)
                                        Text(
                                          update.fields.systemAssignedTo?.oldValue?.displayName == null
                                              ? 'Set assignee to ${update.fields.systemAssignedTo?.newValue?.displayName}'
                                              : 'Changed assignee: ${update.fields.systemAssignedTo?.newValue?.displayName}',
                                        ),
                                      if (update.fields.microsoftVstsSchedulingEffort != null)
                                        Text(
                                          update.fields.microsoftVstsSchedulingEffort?.oldValue == null
                                              ? 'Set effort to ${update.fields.microsoftVstsSchedulingEffort?.newValue}'
                                              : 'Changed effort from ${update.fields.microsoftVstsSchedulingEffort?.oldValue} to ${update.fields.microsoftVstsSchedulingEffort?.newValue}',
                                        ),
                                      if (update.fields.systemHistory != null)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 5),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(AppTheme.radius),
                                                child: ColoredBox(
                                                  color: context.colorScheme.surface,
                                                  child: Html(
                                                    data: update.fields.systemHistory!.newValue!,
                                                    style: {
                                                      'div': Style.fromTextStyle(context.textTheme.labelSmall!),
                                                    },
                                                    onLinkTap: (str, _, __, ___) async {
                                                      final url = str.toString();
                                                      if (await canLaunchUrlString(url)) await launchUrlString(url);
                                                    },
                                                    customRenders: {
                                                      (ctx) => ctx.tree.element?.localName == 'img':
                                                          CustomRender.widget(
                                                        widget: (ctx, child) => Image.network(
                                                          ctx.tree.attributes['src']!,
                                                          headers: ctrl.apiService.headers,
                                                          fit: BoxFit.contain,
                                                          height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
                                                          width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
                                                          frameBuilder: (_, child, frame, __) => frame == null
                                                              ? Center(child: const CircularProgressIndicator())
                                                              : child,
                                                        ),
                                                      ),
                                                      (ctx) => ctx.tree.element?.localName == 'br': CustomRender.widget(
                                                        widget: (ctx, child) => const Text('\n'),
                                                      ),
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (update != ctrl.updates.first) const Divider(height: 30),
                    ],
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
