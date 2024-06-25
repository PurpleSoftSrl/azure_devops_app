import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class DevOpsHtmlEditor extends StatefulWidget {
  const DevOpsHtmlEditor({
    required this.editorController,
    this.initialText,
    this.onKeyUp,
    required this.editorGlobalKey,
    this.height = 250.0,
    this.hint,
    this.showToolbar = true,
    this.autofocus = false,
    this.readOnly = false,
  });

  final String? initialText;
  final void Function(int?)? onKeyUp;
  final HtmlEditorController editorController;
  final String? hint;
  final bool showToolbar;
  final bool autofocus;

  /// Global key of a widget immediately below the editor.
  /// Used to ensure the editor is fully visible when the keyboard shows.
  final GlobalKey<State> editorGlobalKey;

  final double height;

  final bool readOnly;

  @override
  State<DevOpsHtmlEditor> createState() => _DevOpsHtmlEditorState();
}

class _DevOpsHtmlEditorState extends State<DevOpsHtmlEditor> with FilterMixin {
  /// Scrolls the page to make the editor fully visible.
  /// The delay is to wait for the keyboard to show.
  Future<void> _ensureEditorIsVisible() async {
    await Future<void>.delayed(Duration(milliseconds: 500));
    widget.editorController.resetHeight();
    await Future<void>.delayed(Duration(milliseconds: 50));

    final ctx = widget.editorGlobalKey.currentContext;
    if (ctx == null) return;

    if (!ctx.mounted) return;

    await Scrollable.of(ctx).position.ensureVisible(
          ctx.findRenderObject()!,
          duration: Duration(milliseconds: 250),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
  }

  Future<void> _addMention(GraphUser u, AzureApiService apiService) async {
    final res = await apiService.getUserToMention(email: u.mailAddress!);
    if (res.isError || res.data == null) {
      return OverlayService.snackbar('Could not find user', isError: true);
    }

    // remove `(me)` from user name if it's me
    final name = u.mailAddress == apiService.user!.emailAddress ? apiService.user!.displayName : u.displayName;
    final mention = '<a href="#" data-vss-mention="version:2.0,${res.data}">@$name</a>';
    widget.editorController.insertHtml(mention);
  }

  void enable() {
    widget.editorController.enable();
  }

  void disable() {
    widget.editorController.disable();
  }

  @override
  void didUpdateWidget(DevOpsHtmlEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.readOnly && !oldWidget.readOnly) {
      disable();
    } else if (!widget.readOnly && oldWidget.readOnly) {
      enable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return HtmlEditor(
      controller: widget.editorController,
      callbacks: Callbacks(
        onInit: () {
          widget.editorController.setFullScreen();
          if (widget.autofocus) widget.editorController.setFocus();

          if (widget.readOnly) disable();
        },
        onFocus: _ensureEditorIsVisible,
        onKeyUp: widget.onKeyUp,
      ),
      htmlEditorOptions: HtmlEditorOptions(
        initialText: widget.initialText ?? '',
        mobileLongPressDuration: Duration.zero,
        customOptions: 'popover: {link:[]}, ${widget.showToolbar ? '' : 'toolbar:false,'}',
        hint: widget.hint,
      ),
      otherOptions: OtherOptions(
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.surface),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppTheme.radius),
            bottomRight: Radius.circular(AppTheme.radius),
          ),
        ),
      ),
      htmlToolbarOptions: HtmlToolbarOptions(
        defaultToolbarButtons: [
          FontButtons(clearAll: false),
          ColorButtons(),
          ListButtons(listStyles: false),
          ParagraphButtons(textDirection: false, lineHeight: false, caseConverter: false),
          StyleButtons(),
        ],
        textStyle: context.textTheme.headlineSmall,
        customToolbarButtons: [
          ToggleButtons(
            isSelected: const [false],
            disabledBorderColor: Colors.transparent,
            children: [
              FilterMenu<GraphUser>(
                title: '',
                values: getSortedUsers(apiService).whereNot((u) => u.displayName == userAll.displayName).toList(),
                currentFilter: userAll,
                onSelected: (u) => _addMention(u, apiService),
                formatLabel: (u) => getFormattedUser(u, apiService),
                isDefaultFilter: true,
                widgetBuilder: (u) => UserFilterWidget(user: u),
                onSearchChanged: hasManyUsers(apiService) ? (s) => searchUser(s, apiService) : null,
                child: Text(
                  '@',
                  style: context.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ],
        customToolbarInsertionIndices: [1],
        toolbarPosition: widget.showToolbar ? ToolbarPosition.belowEditor : ToolbarPosition.custom,
      ),
    );
  }
}
