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
      fixedAppBar: true,
      actions: [
        ValueListenableBuilder(
          valueListenable: ctrl.hasChanged,
          builder: (_, hasChanged, __) => hasChanged?.data ?? false
              ? TextButton(
                  onPressed: ctrl.confirm,
                  child: Text(
                    'Confirm',
                    style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.primary),
                  ),
                )
              : const SizedBox(),
        ),
      ],
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
              WorkItemTypeFilterMenu(
                title: 'Type',
                values: ctrl.projectWorkItemTypes,
                currentFilter: ctrl.newWorkItemType,
                formatLabel: (t) =>
                    [null, 'system'].contains(t.customization) ? t.name : '${t.name} (${t.customization})',
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
                values: ctrl.getAssignees(),
                currentFilter: ctrl.newWorkItemAssignedTo,
                onSelected: ctrl.setAssignee,
                formatLabel: (u) => u.displayName!,
                isDefaultFilter: ctrl.newWorkItemAssignedTo.displayName == 'Unassigned',
                widgetBuilder: (u) => UserFilterWidget(user: u),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (ctrl.newWorkItemProject != ctrl.projectAll || ctrl.isEditing)
            Row(
              children: [
                Text(
                  'Area:',
                  style: style,
                ),
                const SizedBox(
                  width: 10,
                ),
                FilterMenu<AreaOrIteration?>.custom(
                  title: 'Area',
                  formatLabel: (u) => u?.escapedAreaPath ?? '-',
                  isDefaultFilter: ctrl.newWorkItemArea == null,
                  currentFilter: ctrl.newWorkItemArea,
                  body: AreaFilterBody(
                    currentFilter: ctrl.newWorkItemArea,
                    areasToShow: ctrl.getAreasToShow(),
                    onTap: ctrl.setArea,
                    showAllFilter: false,
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 10,
          ),
          if (ctrl.newWorkItemProject != ctrl.projectAll || ctrl.isEditing)
            Row(
              children: [
                Text(
                  'Iteration:',
                  style: style,
                ),
                const SizedBox(
                  width: 10,
                ),
                FilterMenu<AreaOrIteration?>.custom(
                  title: 'Iteration',
                  formatLabel: (u) => u?.escapedIterationPath ?? '-',
                  isDefaultFilter: ctrl.newWorkItemIteration == null,
                  currentFilter: ctrl.newWorkItemIteration,
                  body: AreaFilterBody(
                    currentFilter: ctrl.newWorkItemIteration,
                    areasToShow: ctrl.getIterationsToShow(),
                    onTap: ctrl.setIteration,
                    showAllFilter: false,
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 20,
          ),
          DevOpsFormField(
            initialValue: ctrl.newWorkItemTitle,
            onChanged: ctrl.onTitleChanged,
            label: 'Title',
            formFieldKey: ctrl.titleFieldKey,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(
            height: 20,
          ),
          for (final field in ctrl.fieldsToShow)
            if (field.type == 'html')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: context.textTheme.labelSmall!.copyWith(height: 1, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DevOpsHtmlEditor(
                    editorController: ctrl.dynamicFields[field.referenceName]!.editorController!,
                    editorGlobalKey: ctrl.dynamicFields[field.referenceName]!.editorGlobalKey!,
                    initialText: ctrl.isEditing
                        ? (ctrl.dynamicFields[field.referenceName]!.editorInitialText ?? field.defaultValue)
                        : field.defaultValue,
                    onKeyUp: (_) => ctrl._setHasChanged(),
                  ),
                  SizedBox(
                    key: ctrl.dynamicFields[field.referenceName]?.editorGlobalKey,
                    height: 0,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DevOpsFormField(
                  onChanged: (s) => ctrl.onFieldChanged(s, field.referenceName),
                  label: field.name,
                  textInputAction: TextInputAction.next,
                  validator: (s) => ctrl.fieldValidator(s, field),
                  formFieldKey: ctrl.dynamicFields[field.referenceName]?.formFieldKey,
                  controller: ctrl.dynamicFields[field.referenceName]?.controller,
                  suffixIcon: field.allowedValues.where((v) => v != '<None>').isEmpty
                      ? null
                      : DevOpsPopupMenu(
                          tooltip: '${field.name} allowed values',
                          offset: const Offset(0, 20),
                          items: () => [
                            for (final value in field.allowedValues)
                              PopupItem(
                                onTap: () => ctrl.onFieldChanged(value, field.referenceName),
                                text: value,
                              ),
                          ],
                        ),
                ),
              ),
        ],
      ),
    );
  }
}
