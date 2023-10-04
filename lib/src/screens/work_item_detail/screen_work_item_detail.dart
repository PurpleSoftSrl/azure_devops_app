part of work_item_detail;

class _WorkItemDetailScreen extends StatelessWidget {
  const _WorkItemDetailScreen(this.ctrl, this.parameters);

  final _WorkItemDetailController ctrl;
  final _WorkItemDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AppPage<WorkItemWithUpdates?>(
          init: ctrl.init,
          dispose: ctrl.dispose,
          title: 'Work Item #${ctrl.args.id}',
          notifier: ctrl.itemDetail,
          actions: [
            DevOpsPopupMenu(
              tooltip: 'work item actions',
              items: () => [
                PopupItem(
                  onTap: ctrl.shareWorkItem,
                  text: 'Share',
                  icon: DevOpsIcons.share,
                ),
                PopupItem(
                  onTap: ctrl.editWorkItem,
                  text: 'Edit',
                  icon: DevOpsIcons.edit,
                ),
                PopupItem(
                  onTap: ctrl.addAttachment,
                  text: 'Add attachment',
                  icon: DevOpsIcons.link,
                ),
                if (!['Test Suite', 'Test Plan'].contains(ctrl.itemDetail.value?.data?.item.fields.systemWorkItemType))
                  PopupItem(
                    onTap: ctrl.deleteWorkItem,
                    text: 'Delete',
                    icon: DevOpsIcons.failed,
                  ),
              ],
            ),
            const SizedBox(
              width: 8,
            ),
          ],
          builder: (detWithUpdates) {
            final detail = detWithUpdates!.item;
            final wType = ctrl.apiService.workItemTypes[detail.fields.systemTeamProject]
                ?.firstWhereOrNull((t) => t.name == detail.fields.systemWorkItemType);
            final state = ctrl
                .apiService.workItemStates[detail.fields.systemTeamProject]?[detail.fields.systemWorkItemType]
                ?.firstWhereOrNull((t) => t.name == detail.fields.systemState);

            return DefaultTextStyle(
              style: context.textTheme.titleSmall!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      WorkItemTypeIcon(type: wType),
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
                      Text(
                        detail.fields.systemState,
                        style: context.textTheme.titleSmall!.copyWith(
                          color: state == null ? null : Color(int.parse(state.color, radix: 16)).withOpacity(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (detail.fields.systemCreatedBy != null)
                    Row(
                      children: [
                        Text(
                          'Created by: ',
                          style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                        ),
                        Text(detail.fields.systemCreatedBy!.displayName!),
                        if (ctrl.apiService.organization.isNotEmpty) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          MemberAvatar(
                            userDescriptor: detail.fields.systemCreatedBy!.descriptor,
                            radius: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                        const Spacer(),
                        Text(detail.fields.systemCreatedDate!.minutesAgo),
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
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        'Area: ',
                        style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                      ),
                      Flexible(child: Text(detail.fields.systemAreaPath)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        'Iteration: ',
                        style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                      ),
                      Flexible(child: Text(detail.fields.systemIterationPath)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Title',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  Text(detail.fields.systemTitle),
                  if (detail.fields.systemAssignedTo != null) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        TextTitleDescription(
                          title: 'Assigned to: ',
                          description: detail.fields.systemAssignedTo!.displayName!,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        MemberAvatar(
                          userDescriptor: detail.fields.systemAssignedTo!.descriptor,
                          radius: 30,
                        ),
                      ],
                    ),
                  ],
                  for (final entry in ctrl.fieldsToShow.entries)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ctrl.shouldShowGroupLabel(group: entry.key)) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              entry.key,
                              style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(),
                        ],
                        for (final field in entry.value)
                          Builder(
                            builder: (context) {
                              final textToShow = detail.fields.jsonFields[field.referenceName] ?? field.defaultValue;
                              if (textToShow == null) return const SizedBox();

                              final shouldShowFieldName = entry.value.length > 1 || field.name != entry.key;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  if (shouldShowFieldName)
                                    Text(
                                      field.name,
                                      style: context.textTheme.titleSmall!
                                          .copyWith(color: context.colorScheme.onSecondary),
                                    ),
                                  if (field.type == 'html')
                                    _HtmlWidget(
                                      data: textToShow.toString(),
                                      style: context.textTheme.titleSmall,
                                    )
                                  else
                                    Text(textToShow!.toString().formatted),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextTitleDescription(
                    title: 'Created at: ',
                    description: detail.fields.systemCreatedDate!.toSimpleDate(),
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
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SectionHeader.noMargin(text: 'History'),
                          IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            constraints: BoxConstraints(maxWidth: 20),
                            onPressed: ctrl.toggleShowUpdatesReversed,
                            icon: Icon(Icons.swap_vert),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      VisibilityDetector(
                        key: ctrl.historyKey,
                        onVisibilityChanged: ctrl.onHistoryVisibilityChanged,
                        child: ValueListenableBuilder(
                          valueListenable: ctrl.showUpdatesReversed,
                          builder: (_, showUpdatesReversed, __) {
                            final updates = showUpdatesReversed ? ctrl.updates.reversed.toList() : ctrl.updates;
                            return _History(
                              updates: updates,
                              ctrl: ctrl,
                            );
                          },
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: ctrl.showCommentField,
                        builder: (_, value, __) => SizedBox(
                          height: value ? 100 : 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        AddCommentField(
          isVisible: ctrl.showCommentField,
          onTap: ctrl.addComment,
        ),
      ],
    );
  }
}
