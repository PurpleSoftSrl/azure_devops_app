import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/commits_tags.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:flutter/material.dart';

class CommitListTile extends StatelessWidget {
  const CommitListTile({
    super.key,
    required this.onTap,
    required this.commit,
    this.showAuthor = true,
    this.showRepo = true,
    required this.isLast,
  });

  final VoidCallback onTap;
  final Commit commit;
  final bool showAuthor;
  final bool showRepo;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodySmall!.copyWith(height: 1);
    return InkWell(
      key: ValueKey('commit_${commit.commitId?.substring(0, 6)}'),
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${commit.comment}',
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge!.copyWith(height: 1),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    if (showAuthor)
                      Text(
                        '${commit.author?.name}',
                        style: subtitleStyle,
                      ),
                    if (showRepo && showAuthor)
                      Text(
                        ' in ',
                        style: subtitleStyle.copyWith(color: context.colorScheme.onSecondary),
                      ),
                    if (showRepo)
                      Expanded(
                        child: Text(
                          commit.repositoryName,
                          overflow: TextOverflow.ellipsis,
                          style: subtitleStyle,
                        ),
                      ),
                    if (!showRepo) const Spacer(),
                    const SizedBox(
                      width: 8,
                    ),
                    if (commit.tags?.isNotEmpty ?? false)
                      for (final tag in commit.tags!)
                        TagChip(
                          tag: tag,
                        ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      commit.author?.date?.minutesAgo ?? '',
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            AppLayoutBuilder(
              smartphone: const Divider(height: 1, thickness: 1),
              tablet: const Divider(height: 10, thickness: 1),
            ),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.labelSmall!.copyWith(height: 1);
    return DevOpsPopupMenu(
      tooltip: tag.name,
      items: () => [
        PopupItem(
          text: '${tag.comment ?? ''}\n${tag.tagger?.name}\n${tag.tagger?.date?.toDate()}',
          onTap: () {},
        ),
      ],
      offset: Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: context.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sell_outlined,
              size: 10,
              color: context.colorScheme.onBackground,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              tag.name,
              style: subtitleStyle,
            ),
          ],
        ),
      ),
    );
  }
}
