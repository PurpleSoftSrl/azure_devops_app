part of create_or_edit_work_item;

class _HtmlFormField extends StatelessWidget {
  const _HtmlFormField({
    required this.field,
    required this.ctrl,
  });

  final WorkItemField field;
  final _CreateOrEditWorkItemController ctrl;

  @override
  Widget build(BuildContext context) {
    final formField = ctrl.formFields[field.referenceName]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ctrl.getFieldName(field),
          style: context.textTheme.labelSmall!.copyWith(height: 1, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        DevOpsHtmlEditor(
          editorController: formField.editorController!,
          editorGlobalKey: formField.editorGlobalKey!,
          initialText: ctrl.isEditing ? (formField.editorInitialText ?? field.defaultValue) : field.defaultValue,
          onKeyUp: (_) => ctrl._setHasChanged(),
          readOnly: field.readOnly,
        ),
        SizedBox(
          key: formField.editorGlobalKey,
          height: 0,
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class _DateFormField extends StatelessWidget {
  const _DateFormField({
    required this.field,
    required this.ctrl,
  });

  final WorkItemField field;
  final _CreateOrEditWorkItemController ctrl;

  @override
  Widget build(BuildContext context) {
    final formField = ctrl.formFields[field.referenceName];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DevOpsFormField(
        onChanged: (s) => true,
        label: ctrl.getFieldName(field),
        readOnly: true,
        onTap: field.readOnly ? null : () => ctrl.setDateField(field.referenceName),
        textInputAction: TextInputAction.next,
        validator: (s) => ctrl.fieldValidator(s, field),
        formFieldKey: formField?.formFieldKey,
        controller: formField?.controller,
      ),
    );
  }
}

class _UserFormField extends StatelessWidget {
  const _UserFormField({required this.field, required this.ctrl});

  final _CreateOrEditWorkItemController ctrl;
  final WorkItemField field;

  @override
  Widget build(BuildContext context) {
    final formField = ctrl.formFields[field.referenceName];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ctrl.getFieldName(field),
          style: context.textTheme.labelSmall!.copyWith(height: 1, fontWeight: FontWeight.bold),
        ),
        FilterMenu<GraphUser>(
          title: formField?.text ?? '-',
          values: ctrl.getAssignees(),
          currentFilter: null,
          onSelected: (u) => ctrl.onFieldChanged(
            u.mailAddress == null ? '' : '${u.displayName} <${u.mailAddress}>',
            field.referenceName,
          ),
          formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
          isDefaultFilter: true,
          widgetBuilder: (u) => UserFilterWidget(user: u),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}

class _SelectionFormField extends StatelessWidget {
  const _SelectionFormField({
    required this.ctrl,
    required this.field,
  });

  final _CreateOrEditWorkItemController ctrl;
  final WorkItemField field;

  @override
  Widget build(BuildContext context) {
    final formField = ctrl.formFields[field.referenceName];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DevOpsFormField(
        onChanged: (s) => true,
        label: ctrl.getFieldName(field),
        readOnly: true,
        onTap: field.readOnly ? null : () => ctrl.showPopupMenu(field.referenceName),
        textInputAction: TextInputAction.next,
        validator: (s) => ctrl.fieldValidator(s, field),
        formFieldKey: formField?.formFieldKey,
        controller: formField?.controller,
        suffix: field.readOnly
            ? null
            : DevOpsPopupMenu(
                menuKey: formField?.popupMenuKey,
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
    );
  }
}

class _DefaultFormField extends StatelessWidget {
  const _DefaultFormField({
    required this.ctrl,
    required this.field,
  });

  final _CreateOrEditWorkItemController ctrl;
  final WorkItemField field;

  @override
  Widget build(BuildContext context) {
    final formField = ctrl.formFields[field.referenceName];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DevOpsFormField(
        onChanged: (s) => ctrl.onFieldChanged(s, field.referenceName),
        label: ctrl.getFieldName(field),
        readOnly: field.readOnly,
        textInputAction: TextInputAction.next,
        validator: (s) => ctrl.fieldValidator(s, field),
        formFieldKey: formField?.formFieldKey,
        controller: formField?.controller,
      ),
    );
  }
}

class _AddTagBottomsheet extends StatelessWidget {
  _AddTagBottomsheet({
    required this.projectTags,
    required this.workItemTags,
    required this.addExistingTag,
    required this.addNewTag,
  });

  final ValueNotifier<Set<String>?> projectTags;
  final Set<String> workItemTags;
  final void Function(String) addExistingTag;
  final bool Function(String) addNewTag;

  final newTagController = TextEditingController();

  void _onSubmit() {
    final tagToAdd = newTagController.text.trim();
    final res = addNewTag(tagToAdd);

    if (res) newTagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DevOpsFormField(
          label: 'New tag',
          maxLines: 1,
          onChanged: (s) => true,
          controller: newTagController,
          validator: (_) => null,
          suffix: ValueListenableBuilder(
            valueListenable: newTagController,
            builder: (_, tagCtrl, ___) => IconButton(
              onPressed: tagCtrl.text.isEmpty ? null : _onSubmit,
              color: Colors.blue,
              disabledColor: Colors.transparent,
              icon: const Icon(Icons.done),
            ),
          ),
          onFieldSubmitted: _onSubmit,
        ),
        const SizedBox(
          height: 20,
        ),
        ValueListenableBuilder(
          valueListenable: projectTags,
          builder: (_, tags, __) => switch (tags) {
            null => const CircularProgressIndicator(),
            [] => const Text('No tags available'),
            _ => Expanded(
                child: ListView.separated(
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final t = tags.toList().sortedBy((t) => t.toLowerCase())[index];
                    return GestureDetector(
                      onTap: () => addExistingTag(t),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t),
                            if (workItemTags.contains(t)) const Icon(DevOpsIcons.success),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          },
        ),
      ],
    );
  }
}
