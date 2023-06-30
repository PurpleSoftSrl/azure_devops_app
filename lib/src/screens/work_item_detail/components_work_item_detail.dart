part of work_item_detail;

class _HtmlWidget extends StatelessWidget {
  const _HtmlWidget({required this.data, this.padding = EdgeInsets.zero, this.style});

  final String data;
  final EdgeInsets padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final defaultTextStyle = context.textTheme.labelMedium!;
    final effectiveStyle = style ?? defaultTextStyle;
    final htmlTextStyle = Style.fromTextStyle(effectiveStyle).copyWith(margin: Margins.zero, padding: padding);
    return Html(
      data: data,
      style: {
        'div': htmlTextStyle,
        'p': htmlTextStyle,
        'body': htmlTextStyle,
        'html': htmlTextStyle,
      },
      onLinkTap: (str, _, __, ___) async {
        final url = str.toString();
        if (await canLaunchUrlString(url)) await launchUrlString(url);
      },
      customRenders: {
        (ctx) => ctx.tree.element?.localName == 'img': CustomRender.widget(
          widget: (ctx, child) {
            final src = ctx.tree.attributes['src'];
            if (src == null) return const SizedBox();

            final isNetworkImage = src.startsWith('http');
            final isBase64 = src.startsWith('data:');

            Widget image;
            if (isNetworkImage) {
              image = CachedNetworkImage(
                imageUrl: src,
                httpHeaders: apiService.headers,
                fit: BoxFit.contain,
                height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
                width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
                placeholder: (_, __) => Center(child: const CircularProgressIndicator()),
              );
            } else if (isBase64) {
              final data = src.split(',').last;
              image = Image.memory(base64Decode(data));
            } else {
              image = const SizedBox();
            }

            late OverlayEntry entry;

            void exitFullScreen() {
              entry.remove();
            }

            void goFullScreen() {
              entry = OverlayEntry(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    actions: [
                      CloseButton(
                        onPressed: exitFullScreen,
                      ),
                    ],
                  ),
                  body: InteractiveViewer(
                    child: SizedBox(
                      height: context.height,
                      width: context.width,
                      child: image,
                    ),
                  ),
                ),
              );

              Overlay.of(context).insert(entry);
            }

            return GestureDetector(
              onTap: goFullScreen,
              child: image,
            );
          },
        ),
        (ctx) => ctx.tree.element?.localName == 'br': CustomRender.widget(
          widget: (ctx, child) => const Text(''),
        ),
        (ctx) => ctx.tree.element?.localName == 'a' && ctx.tree.attributes['data-vss-mention'] != null:
            CustomRender.widget(
          widget: (ctx, child) => GestureDetector(
            onTap: () async {
              final name = ctx.tree.element!.innerHtml.substring(1);
              final user = await apiService.getUserFromDisplayName(name: name);
              if (user.isError) return;

              unawaited(AppRouter.goToMemberDetail(user.data!.descriptor!));
            },
            child: Text(
              ctx.tree.element!.innerHtml,
              style: effectiveStyle.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ),
      },
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.updates, required this.ctrl});

  final List<ItemUpdate> updates;
  final _WorkItemDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: updates.map(
        (update) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MemberAvatar(userDescriptor: update.updatedBy.descriptor, radius: 15),
                  const SizedBox(width: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: update.updatedBy.displayName),
                        if (update is CommentItemUpdate)
                          TextSpan(
                            text: '  commented ${update.isEdited ? '(edited)' : ''}',
                            style: context.textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(update.updateDate.minutesAgo),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              switch (update) {
                SimpleItemUpdate() => _SimpleUpdateWidget(ctrl: ctrl, update: update),
                CommentItemUpdate() => _CommentWidget(ctrl: ctrl, update: update),
              },
              if (update != updates.last) const Divider(height: 30),
            ],
          );
        },
      ).toList(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: PopupMenuButton<void>(
            key: ValueKey('Popup menu work item comment'),
            itemBuilder: (_) => [
              PopupMenuItem<void>(
                onTap: () => ctrl.deleteWorkItemComment(update),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delete',
                      style: context.textTheme.titleSmall,
                    ),
                    Icon(Icons.delete),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                onTap: () => ctrl.editWorkItemComment(update),
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
            ],
            elevation: 0,
            tooltip: 'Work item comment actions',
            offset: const Offset(0, 40),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            child: Icon(DevOpsIcons.dots_horizontal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: ColoredBox(
              color: context.colorScheme.surface,
              child: _HtmlWidget(
                data: update.text,
                padding: const EdgeInsets.all(3),
              ),
            ),
          ),
        ),
      ],
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
                      TextSpan(text: isRemoved ? 'Removed ' : isEdited ? 'Edited ' : 'Added '),
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

class _AddCommentField extends StatefulWidget {
  const _AddCommentField({required this.isVisible, required this.onTap});

  final ValueNotifier<bool> isVisible;
  final Future<void> Function() onTap;

  @override
  State<_AddCommentField> createState() => __AddCommentFieldState();
}

class __AddCommentFieldState extends State<_AddCommentField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  void _listener() {
    if (widget.isVisible.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    widget.isVisible.addListener(_listener);
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation = Tween<Offset>(begin: Offset(0, 1.5), end: Offset.zero).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.isVisible.removeListener(_listener);
    widget.isVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final me = apiService.allUsers.firstWhereOrNull((u) => u.mailAddress == apiService.user!.emailAddress);
    return SlideTransition(
      position: _animation,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radius),
            topRight: Radius.circular(AppTheme.radius),
          ),
          child: Material(
            child: Container(
              color: context.colorScheme.surface,
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  if (me != null) MemberAvatar(userDescriptor: me.descriptor!),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onTap,
                      child: DevOpsFormField(
                        onChanged: (_) => true,
                        hint: 'Add comment',
                        enabled: false,
                        maxLines: 2,
                        fillColor: context.colorScheme.background,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
