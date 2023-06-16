part of create_or_edit_work_item;

class _CreateOrEditWorkItemScreen extends StatelessWidget {
  const _CreateOrEditWorkItemScreen(this.ctrl, this.parameters);

  final _CreateOrEditWorkItemController ctrl;
  final _CreateOrEditWorkItemParameters parameters;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodySmall!.copyWith(height: 1, fontWeight: FontWeight.bold);
    return AppPage<bool>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: ctrl.args.id == null ? 'Create work item' : 'Edit work item #${ctrl.args.id}',
      notifier: ctrl.hasChanged,
      builder: (hasChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!ctrl.isEditing) ...[
            Row(
              children: [
                Text(
                  'Project:',
                  style: style,
                ),
                const SizedBox(
                  width: 10,
                ),
                FilterMenu<Project>(
                  title: 'Project',
                  values: ctrl.getProjects(ctrl.storageService).where((p) => p != ctrl.projectAll).toList(),
                  currentFilter: ctrl.newWorkItemProject,
                  onSelected: ctrl.setProject,
                  formatLabel: (p) => p.name!,
                  isDefaultFilter: ctrl.newWorkItemProject == ctrl.projectAll,
                  widgetBuilder: (p) => ProjectFilterWidget(project: p),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
          Row(
            children: [
              Text(
                'Type:',
                style: style,
              ),
              const SizedBox(
                width: 10,
              ),
              FilterMenu<WorkItemType>(
                title: 'Type',
                values: ctrl.projectWorkItemTypes,
                currentFilter: ctrl.newWorkItemType,
                formatLabel: (t) => t.name,
                onSelected: ctrl.setType,
                isDefaultFilter: ctrl.newWorkItemType == WorkItemType.all,
                widgetBuilder: (t) => WorkItemTypeFilter(type: t),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (ctrl.isEditing) ...[
            Row(
              children: [
                Text(
                  'Status:',
                  style: style,
                ),
                const SizedBox(
                  width: 10,
                ),
                FilterMenu<WorkItemState>(
                  title: 'Status',
                  values: ctrl.allWorkItemStates,
                  currentFilter: ctrl.newWorkItemStatus!,
                  formatLabel: (t) => t.name,
                  onSelected: ctrl.setState,
                  isDefaultFilter: false,
                  widgetBuilder: (s) => WorkItemStateFilterWidget(state: s),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
          Row(
            children: [
              Text(
                'Assigned to:',
                style: style,
              ),
              const SizedBox(
                width: 10,
              ),
              FilterMenu<GraphUser>(
                title: 'Assigned to',
                values: ctrl
                    .getSortedUsers(ctrl.apiService)
                    .whereNot((u) => u.displayName == ctrl.userAll.displayName)
                    .toList(),
                currentFilter: ctrl.newWorkItemAssignedTo,
                onSelected: ctrl.setAssignee,
                formatLabel: (u) => u.displayName!,
                isDefaultFilter: ctrl.newWorkItemAssignedTo.displayName == ctrl.userAll.displayName,
                widgetBuilder: (u) => UserFilterWidget(user: u),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          DevOpsFormField(
            initialValue: ctrl.newWorkItemTitle,
            onChanged: (value) => ctrl.newWorkItemTitle = value,
            label: 'Title',
            formFieldKey: ctrl.titleFieldKey,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Description',
            style: context.textTheme.labelSmall!.copyWith(height: 1, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          DevOpsHtmlEditor(
            editorController: ctrl.editorController,
            editorGlobalKey: ctrl.editorGlobalKey,
            initialText: ctrl.newWorkItemDescription,
            onKeyUp: (_) => ctrl._setHasChanged(),
          ),
          SizedBox(
            key: ctrl.editorGlobalKey,
            height: 40,
          ),
          if (hasChanged)
            LoadingButton(
              onPressed: ctrl.confirm,
              text: 'Confirm',
            ),
        ],
      ),
    );
  }
}
