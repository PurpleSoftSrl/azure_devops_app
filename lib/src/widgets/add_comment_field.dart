import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/html_editor.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class AddCommentField extends StatefulWidget {
  const AddCommentField({required this.isVisible, required this.onTap});

  final ValueNotifier<bool> isVisible;
  final Future<void> Function() onTap;

  @override
  State<AddCommentField> createState() => _AddCommentFieldState();
}

class _AddCommentFieldState extends State<AddCommentField> with SingleTickerProviderStateMixin {
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
    final apiService = context.api;
    final me = apiService.allUsers.firstWhereOrNull((u) => u.mailAddress == apiService.user!.emailAddress);
    return SlideTransition(
      position: _animation,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .2),
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
                  if (me != null) MemberAvatar(userDescriptor: me.descriptor),
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
                        fillColor: context.themeExtension.background,
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

Future<bool> showEditor(
  HtmlEditorController controller,
  GlobalKey<State<StatefulWidget>> globalKey, {
  String? initialText,
  required String title,
}) async {
  var confirm = false;

  final hasChanged = ValueNotifier<bool>(false);

  await OverlayService.bottomsheet(
    heightPercentage: .9,
    isScrollControlled: true,
    title: title,
    topRight: ValueListenableBuilder<bool>(
      valueListenable: hasChanged,
      builder: (context, changed, __) => SizedBox(
        width: 80,
        height: 20,
        child: !changed
            ? Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: AppRouter.popRoute,
                  child: Icon(Icons.close),
                ),
              )
            : TextButton(
                onPressed: () {
                  confirm = true;
                  AppRouter.popRoute();
                },
                style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                child: Text(
                  'Confirm',
                  style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.primary),
                ),
              ),
      ),
    ),
    builder: (context) => ListView(
      children: [
        DevOpsHtmlEditor(
          autofocus: true,
          editorController: controller,
          editorGlobalKey: globalKey,
          onKeyUp: (_) {
            if (!hasChanged.value) hasChanged.value = true;
          },
          initialText: initialText,
        ),
        SizedBox(key: globalKey),
      ],
    ),
  );

  return confirm;
}

Future<String?> getTextFromEditor(HtmlEditorController editorController) async {
  final comment = await editorController.getText();

  if (comment.trim().isEmpty) return null;

  final trimmed = comment.trim().replaceAll(' ', '');
  if (trimmed == '<br>' || trimmed == '<div><br></div>') return null;

  return comment;
}

String translateMentionsFromHtmlToMarkdown(String comment) {
  const mentionStr = '<a href="#" data-vss-mention="version:2.0,';
  final mentionsCount = mentionStr.allMatches(comment).length;
  var newComment = comment;

  if (mentionsCount > 0) {
    for (var i = 0; i < mentionsCount; i++) {
      final mentionIndex = newComment.indexOf(mentionStr);
      final mentionGuidIndex = mentionIndex + mentionStr.length;
      final mentionGuidEndIndex = newComment.indexOf('"', mentionGuidIndex);
      final mentionGuid = newComment.substring(mentionGuidIndex, mentionGuidEndIndex);
      final mentionEndIndex = newComment.indexOf('</a>', mentionGuidEndIndex) + '</a>'.length;
      newComment = newComment.replaceRange(mentionIndex, mentionEndIndex, '@<$mentionGuid>');
    }
  }

  return newComment;
}
