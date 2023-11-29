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
                  currentFilter: ctrl.newWorkItemState!,
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
              Flexible(
                child: FilterMenu<GraphUser>(
                  title: 'Assigned to',
                  values: ctrl.getAssignees(),
                  currentFilter: ctrl.newWorkItemAssignedTo,
                  onSelected: ctrl.setAssignee,
                  formatLabel: (u) => u.displayName!,
                  isDefaultFilter: ctrl.newWorkItemAssignedTo.displayName == 'Unassigned',
                  widgetBuilder: (u) => UserFilterWidget(user: u),
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
                  'Area:',
                  style: style,
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: FilterMenu<AreaOrIteration?>.custom(
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
                Flexible(
                  child: FilterMenu<AreaOrIteration?>.custom(
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
          if (ctrl.fieldsToShow.isEmpty)
            SizedBox(
              height: 100,
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            for (final entry in ctrl.fieldsToShow.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.value.isNotEmpty && (entry.value.length > 1 || entry.value.single.name != entry.key))
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Text(
                        entry.key,
                        style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  for (final field in entry.value)
                    switch (field.type) {
                      'html' => _HtmlFormField(field: field, ctrl: ctrl),
                      'dateTime' => _DateFormField(field: field, ctrl: ctrl),
                      _ when field.hasMeaningfulAllowedValues => _SelectionFormField(ctrl: ctrl, field: field),
                      _ => _DefaultFormField(ctrl: ctrl, field: field),
                    },
                ],
              ),
        ],
      ),
    );
  }
}
