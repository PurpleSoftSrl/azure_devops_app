part of work_item_detail;

class _WorkItemDetailScreen extends StatelessWidget {
  const _WorkItemDetailScreen(this.ctrl, this.parameters);

  final _WorkItemDetailController ctrl;
  final _WorkItemDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    final item = ctrl.item;
    return AppPageListenable<WorkItemDetail?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: '${item.workItemType.name} ${item.id}',
      notifier: ctrl.itemDetail,
      onEmpty: (_) => Text('No work item found'),
      actions: [
        IconButton(
          onPressed: ctrl.shareWorkItem,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      builder: (detail) => DefaultTextStyle(
        style: context.textTheme.titleSmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                WorkItemType.fromString(detail!.fields.systemWorkItemType).icon,
                const SizedBox(
                  width: 20,
                ),
                Text(detail.fields.systemWorkItemType),
                const SizedBox(
                  width: 10,
                ),
                Text(detail.id.toString()),
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
                const SizedBox(
                  width: 10,
                ),
                Text(detail.fields.systemState),
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
