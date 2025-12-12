part of create_or_edit_work_item;

class _HtmlFormField extends StatelessWidget {
  const _HtmlFormField({required this.field, required this.ctrl});

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
        const SizedBox(height: 10),
        DevOpsHtmlEditor(
          editorController: formField.editorController!,
          editorGlobalKey: formField.editorGlobalKey!,
          initialText: ctrl.isEditing ? (formField.editorInitialText ?? field.defaultValue) : field.defaultValue,
          onKeyUp: (_) => ctrl._setHasChanged(),
          readOnly: field.readOnly,
        ),
        SizedBox(key: formField.editorGlobalKey, height: 0),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _DateFormField extends StatelessWidget {
  const _DateFormField({required this.field, required this.ctrl});

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
          formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.api),
          isDefaultFilter: true,
          widgetBuilder: (u) => UserFilterWidget(user: u),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SelectionFormField extends StatelessWidget {
  const _SelectionFormField({required this.ctrl, required this.field});

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
                    PopupItem(onTap: () => ctrl.onFieldChanged(value, field.referenceName), text: value),
                ],
              ),
      ),
    );
  }
}

class _DefaultFormField extends StatelessWidget {
  const _DefaultFormField({required this.ctrl, required this.field});

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
            builder: (_, tagCtrl, _) => IconButton(
              onPressed: tagCtrl.text.isEmpty ? null : _onSubmit,
              color: Colors.blue,
              disabledColor: Colors.transparent,
              icon: const Icon(Icons.done),
            ),
          ),
          onFieldSubmitted: _onSubmit,
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder(
          valueListenable: projectTags,
          builder: (_, tags, _) => switch (tags) {
            null => const CircularProgressIndicator(),
            [] => const Text('No tags available'),
            _ => Expanded(
              child: ListView.separated(
                itemCount: tags.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final t = tags.toList().sortedBy((t) => t.toLowerCase())[index];
                  return GestureDetector(
                    onTap: () => addExistingTag(t),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(t), if (workItemTags.contains(t)) const Icon(DevOpsIcons.success)],
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

class _AddLinkBottomsheet extends StatefulWidget {
  const _AddLinkBottomsheet({
    required this.linkTypes,
    required this.hasChanged,
    required this.getWorkItems,
    required this.formKey,
    required this.addedLink,
  });

  final List<LinkType> linkTypes;
  final ValueNotifier<bool> hasChanged;
  final Future<List<WorkItem>> Function(String) getWorkItems;
  final GlobalKey<FormState> formKey;
  final WorkItemLink addedLink;

  @override
  State<_AddLinkBottomsheet> createState() => _AddLinkBottomsheetState();
}

class _AddLinkBottomsheetState extends State<_AddLinkBottomsheet> {
  final _linkTypeController = TextEditingController();
  final _linkedItemController = TextEditingController();
  final _commentController = TextEditingController();

  final _workItems = ValueNotifier<List<WorkItem>?>([]);
  final _hasSelectedWorkItem = ValueNotifier<bool>(false);

  Timer? _timer;

  static const double _initialHeight = 50;
  double _height = _initialHeight;

  @override
  void initState() {
    super.initState();
    final childType = widget.linkTypes.firstWhereOrNull((t) => t.name == 'Child');
    if (childType != null) _setLinkType(childType);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getWorkItems(String query) async {
    _timer?.cancel();

    _timer = Timer(const Duration(milliseconds: 500), () async {
      _workItems
        ..value = null
        ..value = await widget.getWorkItems(query);
      _height = _workItems.value!.isNotEmpty ? 300 : _initialHeight;
    });
  }

  void _setLinkType(LinkType type) {
    _linkTypeController.text = type.name;

    widget.addedLink.linkTypeReferenceName = type.referenceName;
    widget.addedLink.linkTypeName = type.name;
  }

  void _addLinkedItem(WorkItem item) {
    widget.hasChanged.value = true;

    _linkedItemController.text = '${item.id} - ${item.fields.systemTitle}';

    _height = _initialHeight;
    _workItems.value = [];

    widget.addedLink.linkedWorkItemId = item.id;

    _hasSelectedWorkItem.value = true;
  }

  void _removeSelectedWorkItem() {
    _linkedItemController.clear();
    _hasSelectedWorkItem.value = false;
  }

  // ignore: use_setters_to_change_properties
  void _addComment(String str) {
    widget.addedLink.comment = str;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        children: [
          DevOpsFormField(
            label: 'Link type',
            maxLines: 1,
            onChanged: (s) => true,
            controller: _linkTypeController,
            readOnly: true,
            suffix: DevOpsPopupMenu(
              tooltip: 'Link types',
              items: () => [
                for (final type in widget.linkTypes) PopupItem(onTap: () => _setLinkType(type), text: type.name),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder(
            valueListenable: _hasSelectedWorkItem,
            builder: (_, hasSelected, _) => DevOpsFormField(
              label: 'Linked work item',
              maxLines: 1,
              onChanged: _getWorkItems,
              controller: _linkedItemController,
              hint: 'Search by ID or title',
              readOnly: hasSelected,
              suffix: ValueListenableBuilder(
                valueListenable: _linkedItemController,
                builder: (_, ctrl, _) => IconButton(
                  onPressed: ctrl.text.isEmpty ? null : _removeSelectedWorkItem,
                  color: Colors.blue,
                  disabledColor: Colors.transparent,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder(
            valueListenable: _workItems,
            builder: (_, items, _) => AnimatedContainer(
              height: _height,
              duration: Duration(milliseconds: 250),
              child: switch (items) {
                null => Center(child: const CircularProgressIndicator()),
                [] when _linkedItemController.text.isNotEmpty && !_hasSelectedWorkItem.value => Text(
                  'No work items found',
                  style: context.textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                _ => ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    final wt = context.api.workItemTypes[item.fields.systemTeamProject]?.firstWhereOrNull(
                      (t) => t.name == item.fields.systemWorkItemType,
                    );

                    return GestureDetector(
                      onTap: () => _addLinkedItem(item),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            WorkItemTypeIcon(type: wt),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text('${item.id} - ${item.fields.systemTitle}', overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              },
            ),
          ),
          DevOpsFormField(
            label: 'Comment',
            maxLines: 3,
            onChanged: _addComment,
            controller: _commentController,
            validator: (_) => null,
            suffix: ValueListenableBuilder(
              valueListenable: _commentController,
              builder: (_, ctrl, _) => IconButton(
                onPressed: ctrl.text.isEmpty ? null : _commentController.clear,
                color: Colors.blue,
                disabledColor: Colors.transparent,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
