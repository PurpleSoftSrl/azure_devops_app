part of work_item_detail;

class _HtmlWidget extends StatelessWidget {
  const _HtmlWidget({required this.data, this.padding = EdgeInsets.zero});

  final String data;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final textStyle =
        Style.fromTextStyle(context.textTheme.labelMedium!).copyWith(margin: Margins.zero, padding: padding);
    return Html(
      data: data,
      style: {
        'div': textStyle,
        'p': textStyle,
        'body': textStyle,
        'html': textStyle,
      },
      onLinkTap: (str, _, __, ___) async {
        final url = str.toString();
        if (await canLaunchUrlString(url)) await launchUrlString(url);
      },
      customRenders: {
        (ctx) => ctx.tree.element?.localName == 'img': CustomRender.widget(
          widget: (ctx, child) {
            final image = CachedNetworkImage(
              imageUrl: ctx.tree.attributes['src']!,
              httpHeaders: apiService.headers,
              fit: BoxFit.contain,
              height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
              width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
              placeholder: (_, __) => Center(child: const CircularProgressIndicator()),
            );

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
          widget: (ctx, child) => const Text('\n'),
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
              style: context.textTheme.labelSmall!.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ),
      },
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.updates});

  final List<WorkItemUpdate> updates;

  @override
  Widget build(BuildContext context) {
    final updatesToShow = updates.where((u) => u.hasSUpportedChanges);
    return Column(
      children: updatesToShow.map(
        (update) {
          final isFirst = update.rev == 1;
          final fields = update.fields;
          if (fields == null) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MemberAvatar(userDescriptor: update.revisedBy.descriptor, radius: 15),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(update.revisedBy.displayName),
                  const Spacer(),
                  if (fields.systemChangedDate?.newValue != null)
                    Text(DateTime.tryParse(fields.systemChangedDate!.newValue!)!.minutesAgo),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              DefaultTextStyle(
                style: context.textTheme.labelSmall!.copyWith(
                  fontFamily: AppTheme.defaultFont,
                  fontWeight: FontWeight.w200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirst)
                      Text(
                        'Created work item',
                      ),
                    if (fields.systemWorkItemType?.newValue != null)
                      Text(
                        fields.systemWorkItemType?.oldValue == null
                            ? 'Set type to ${fields.systemWorkItemType?.newValue}'
                            : 'Changed type to ${fields.systemWorkItemType?.newValue}',
                      ),
                    if (!isFirst && fields.systemState?.newValue != null)
                      Text(
                        fields.systemState?.oldValue == null
                            ? 'Set state to ${fields.systemState?.newValue}'
                            : 'Changed state to ${fields.systemState?.newValue}',
                      ),
                    if (fields.systemAssignedTo?.newValue?.displayName != null)
                      Text(
                        fields.systemAssignedTo?.oldValue?.displayName == null
                            ? 'Set assignee to ${fields.systemAssignedTo?.newValue?.displayName}'
                            : 'Changed assignee: ${fields.systemAssignedTo?.newValue?.displayName}',
                      ),
                    if (fields.microsoftVstsSchedulingEffort != null)
                      Text(
                        fields.microsoftVstsSchedulingEffort?.oldValue == null
                            ? 'Set effort to ${fields.microsoftVstsSchedulingEffort?.newValue}'
                            : 'Changed effort from ${fields.microsoftVstsSchedulingEffort?.oldValue} to ${fields.microsoftVstsSchedulingEffort?.newValue}',
                      ),
                    if (fields.systemTitle != null)
                      Text(
                        fields.systemTitle?.oldValue == null
                            ? "Set title to '${fields.systemTitle?.newValue}'"
                            : "Changed title from '${fields.systemTitle?.oldValue}' to '${fields.systemTitle?.newValue}'",
                      ),
                    if (fields.systemHistory != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radius),
                              child: ColoredBox(
                                color: context.colorScheme.surface,
                                child: _HtmlWidget(
                                  data: fields.systemHistory!.newValue!,
                                  padding: const EdgeInsets.all(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (update != updatesToShow.last) const Divider(height: 30),
            ],
          );
        },
      ).toList(),
    );
  }
}
