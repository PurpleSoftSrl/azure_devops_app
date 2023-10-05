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
          field.name,
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
        label: field.name,
        readOnly: true,
        onTap: () => ctrl.setDateField(field.referenceName),
        textInputAction: TextInputAction.next,
        validator: (s) => ctrl.fieldValidator(s, field),
        formFieldKey: formField?.formFieldKey,
        controller: formField?.controller,
      ),
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
        label: field.name,
        readOnly: true,
        onTap: () => ctrl.showPopupMenu(field.referenceName),
        textInputAction: TextInputAction.next,
        validator: (s) => ctrl.fieldValidator(s, field),
        formFieldKey: formField?.formFieldKey,
        controller: formField?.controller,
        suffixIcon: DevOpsPopupMenu(
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
        label: field.name,
        textInputAction: TextInputAction.next,
        validator: (s) => ctrl.fieldValidator(s, field),
        formFieldKey: formField?.formFieldKey,
        controller: formField?.controller,
      ),
    );
  }
}
