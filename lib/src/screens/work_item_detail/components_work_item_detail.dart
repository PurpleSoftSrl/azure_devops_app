part of work_item_detail;

class _History extends StatelessWidget {
  const _History({required this.updates, required this.ctrl});

  final List<ItemUpdate> updates;
  final _WorkItemDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: updates
          .map(
            (update) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                switch (update) {
                  SimpleItemUpdate() => _SimpleUpdateWidget(ctrl: ctrl, update: update),
                  CommentItemUpdate() => _CommentWidget(ctrl: ctrl, update: update),
                },
                if (update != updates.last) const Divider(height: 30),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _SimpleUpdateWidget extends StatelessWidget {
  const _SimpleUpdateWidget({
    required this.ctrl,
    required this.update,
  });

  final _WorkItemDetailController ctrl;
  final SimpleItemUpdate update;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.labelSmall!.copyWith(
        fontFamily: AppTheme.defaultFont,
        fontWeight: FontWeight.w200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MemberAvatar(userDescriptor: update.updatedBy.descriptor, radius: 15),
              const SizedBox(width: 10),
              Text(
                update.updatedBy.displayName,
                style: context.textTheme.titleSmall,
              ),
              const Spacer(),
              Text(update.updateDate.minutesAgo),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (update.isFirst)
            Text(
              'Created work item',
            ),
          if (update.type != null)
            Text(
              update.type!.oldValue == null
                  ? 'Set type to ${update.type!.newValue}'
                  : 'Changed type from ${update.type!.oldValue} to ${update.type!.newValue}',
            ),
          if (!update.isFirst && update.state != null)
            Text(
              update.state!.oldValue == null
                  ? 'Set state to ${update.state!.newValue}'
                  : 'Changed state to ${update.state!.newValue}',
            ),
          if (update.assignedTo?.oldValue != null || update.assignedTo?.newValue != null)
            Text(
              update.assignedTo!.oldValue == null
                  ? 'Assigned to ${update.assignedTo!.newValue?.displayName}'
                  : update.assignedTo!.newValue == null
                      ? 'Unassigned ${update.assignedTo!.oldValue?.displayName}'
                      : 'Changed assignee: ${update.assignedTo!.newValue?.displayName}',
            ),
          if (update.effort != null)
            Text(
              update.effort!.oldValue == null
                  ? 'Set effort to ${update.effort!.newValue}'
                  : 'Changed effort from ${update.effort!.oldValue} to ${update.effort!.newValue}',
            ),
          if (update.title != null)
            Text(
              update.title!.oldValue == null
                  ? "Set title to '${update.title!.newValue}'"
                  : "Changed title from '${update.title!.oldValue}' to '${update.title!.newValue}'",
            ),
          if (update.relations?.added != null)
            for (final att in update.relations!.added!) _AttachmentRow(ctrl: ctrl, att: att),
          if (update.relations?.updated != null)
            for (final att in update.relations!.updated!) _AttachmentRow(ctrl: ctrl, att: att, isEdited: true),
          if (update.relations?.removed != null)
            for (final att in update.relations!.removed!) _AttachmentRow(ctrl: ctrl, att: att, isRemoved: true),
        ],
      ),
    );
  }
}

class _CommentWidget extends StatelessWidget {
  const _CommentWidget({
    required this.ctrl,
    required this.update,
  });

  final _WorkItemDetailController ctrl;
  final CommentItemUpdate update;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: ColoredBox(
        color: context.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  MemberAvatar(userDescriptor: update.updatedBy.descriptor, radius: 15),
                  const SizedBox(width: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: update.updatedBy.displayName),
                        TextSpan(
                          text: '  ${update.isEdited ? '(edited)' : ''}',
                          style: context.textTheme.labelSmall,
                        ),
                        TextSpan(
                          text: '  ${update.updateDate.minutesAgo}',
                          style: context.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  DevOpsPopupMenu(
                    tooltip: 'work item comment',
                    offset: const Offset(0, 20),
                    items: () => [
                      PopupItem(
                        onTap: () => ctrl.deleteWorkItemComment(update),
                        text: 'Delete',
                        icon: DevOpsIcons.failed,
                      ),
                      PopupItem(
                        onTap: () => ctrl.editWorkItemComment(update),
                        text: 'Edit',
                        icon: DevOpsIcons.edit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            if (update.format == 'markdown')
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
                child: MarkdownBody(
                  data: update.text,
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(p: context.textTheme.labelMedium),
                  onTapLink: (_, url, ___) async {
                    if (await canLaunchUrlString(url!)) await launchUrlString(url);
                  },
                ),
              )
            else if (update.format == 'html')
              HtmlWidget(
                data: update.text,
                padding: const EdgeInsets.all(3),
              ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.ctrl, required this.att, this.isRemoved = false, this.isEdited = false});

  final _WorkItemDetailController ctrl;
  final Relation att;
  final bool isRemoved;
  final bool isEdited;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ctrl.openAttachment(att),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ValueListenableBuilder(
              valueListenable: ctrl.isDownloadingAttachment,
              builder: (_, isDownloading, __) => (isDownloading[att.attributes?.id] ?? false)
                  ? SizedBox(
                      width: 15,
                      height: 15,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : RotatedBox(
                      quarterTurns: 1,
                      child: Icon(Icons.attachment, size: 15),
                    ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Builder(
                builder: (ctx) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isRemoved
                            ? 'Removed '
                            : isEdited
                                ? 'Edited '
                                : 'Added ',
                      ),
                      TextSpan(
                        text: att.attributes?.name ?? '-',
                        style: DefaultTextStyle.of(ctx)
                            .style
                            .copyWith(decoration: isRemoved ? null : TextDecoration.underline),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
