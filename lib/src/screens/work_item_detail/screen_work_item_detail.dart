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
              RichText(
                text: HTML.toTextSpan(
                  context,
                  defaultTextStyle: context.textTheme.titleSmall,
                  detail.fields.systemDescription!,
                ),
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
          ],
        ),
      ),
    );
  }
}
