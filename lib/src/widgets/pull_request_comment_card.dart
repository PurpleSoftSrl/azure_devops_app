import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/models/pull_request_with_details.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/html_widget.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:flutter/material.dart';

class PullRequestCommentCard extends StatelessWidget {
  const PullRequestCommentCard({
    required this.comment,
    required this.threadId,
    required this.borderRadiusBottom,
    required this.borderRadiusTop,
    required this.onEditComment,
    required this.onAddComment,
    required this.onDeleteComment,
    this.threadContext,
  });

  final int threadId;
  final PrComment comment;
  final bool borderRadiusTop;
  final bool borderRadiusBottom;
  final Future<void> Function()? onEditComment;
  final Future<void> Function() onAddComment;
  final Future<void> Function()? onDeleteComment;
  final ThreadContext? threadContext;

  @override
  Widget build(BuildContext context) {
    final isEdited = comment.publishedDate.isBefore(comment.lastUpdatedDate);
    final isReply = comment.parentCommentId > 0;

    var commentText = '';
    if (isEdited) {
      commentText += comment.lastUpdatedDate.minutesAgo;
    } else {
      commentText += comment.publishedDate.minutesAgo;
    }

    if (isReply) commentText += ' replied';

    if (comment.isDeleted) {
      commentText += ' (deleted)';
    } else if (isEdited) {
      commentText += ' (edited)';
    }

    String? lineNumber;
    if (threadContext != null) {
      lineNumber = (threadContext!.leftFileStart ?? threadContext!.rightFileStart)?.line.toString();
    }

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.only(top: !borderRadiusTop ? 1 : 0),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadiusBottom ? AppTheme.radius : 0),
          bottomRight: Radius.circular(borderRadiusBottom ? AppTheme.radius : 0),
          topLeft: Radius.circular(borderRadiusTop ? AppTheme.radius : 0),
          topRight: Radius.circular(borderRadiusTop ? AppTheme.radius : 0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (threadContext != null) ...[
            Row(
              children: [
                Flexible(
                  child: Text(
                    threadContext!.filePath,
                    style: context.textTheme.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                if (lineNumber != null)
                  Text(
                    '(line $lineNumber)',
                    style: context.textTheme.labelSmall,
                  ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
          ],
          Row(
            children: [
              MemberAvatar(userDescriptor: comment.author.descriptor, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: comment.author.displayName),
                      TextSpan(
                        text: '  $commentText',
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
              if (!comment.isDeleted)
                DevOpsPopupMenu(
                  tooltip: 'pull request comment',
                  offset: const Offset(0, 20),
                  items: () => [
                    if (onEditComment != null)
                      PopupItem(
                        onTap: onEditComment!,
                        text: 'Edit',
                        icon: DevOpsIcons.edit,
                      ),
                    PopupItem(
                      onTap: onAddComment,
                      text: 'Reply',
                      icon: DevOpsIcons.send,
                    ),
                    if (onDeleteComment != null)
                      PopupItem(
                        onTap: onDeleteComment!,
                        text: 'Delete',
                        icon: DevOpsIcons.failed,
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          HtmlWidget(
            data: comment.content,
          ),
        ],
      ),
    );
  }
}
