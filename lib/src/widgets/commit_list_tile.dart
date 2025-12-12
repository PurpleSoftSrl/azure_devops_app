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
    final subtitleStyle = context.textTheme.bodySmall!;
    return InkWell(
      key: ValueKey('commit_${commit.commitId?.substring(0, 6)}'),
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${commit.comment}', overflow: TextOverflow.ellipsis, style: context.textTheme.labelLarge),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (showAuthor) Text('${commit.author?.name}', style: subtitleStyle),
                    if (showRepo && showAuthor)
                      Text(' in ', style: subtitleStyle.copyWith(color: context.colorScheme.onSecondary)),
                    if (showRepo)
                      Expanded(
                        child: Text(commit.repositoryName, overflow: TextOverflow.ellipsis, style: subtitleStyle),
                      ),
                    if (!showRepo) const Spacer(),
                    const SizedBox(width: 8),
                    if (commit.tags?.isNotEmpty ?? false)
                      if (commit.tags!.length > 1)
                        TagChipMultiple(tags: commit.tags!)
                      else
                        TagChip(tag: commit.tags!.first),
                    const SizedBox(width: 8),
                    Text(commit.author?.date?.minutesAgo ?? '', style: subtitleStyle),
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

  String get _getTagDescription {
    var description = tag.comment ?? '';
    if (tag.tagger != null) {
      description += '\n${tag.tagger!.name ?? ''}';
      description += '\n${tag.tagger?.date?.toDate() ?? ''}';
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    return DevOpsPopupMenu(
      tooltip: tag.name,
      items: () => [if (_getTagDescription.isNotEmpty) PopupItem(text: _getTagDescription, onTap: () {})],
      offset: const Offset(0, 20),
      child: _TagChip(label: tag.name),
    );
  }
}

class TagChipMultiple extends StatelessWidget {
  const TagChipMultiple({required this.tags});

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    return DevOpsPopupMenu(
      tooltip: tags.map((tag) => tag.name).join(', '),
      items: () => [for (final tag in tags) PopupItem(text: tag.name, onTap: () {})],
      offset: const Offset(0, 20),
      child: _TagChip(label: '${tags.length} tags'),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.labelSmall!.copyWith(height: 1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell_outlined, size: 10, color: context.themeExtension.onBackground),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: subtitleStyle)),
        ],
      ),
    );
  }
}
