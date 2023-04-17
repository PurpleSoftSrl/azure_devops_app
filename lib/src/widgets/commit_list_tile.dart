import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/theme/theme.dart';
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
            LayoutBuilder(
              builder: (_, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
                  ? const Divider(
                      height: 1,
                      thickness: 1,
                    )
                  : const Divider(
                      height: 10,
                      thickness: 1,
                    ),
            ),
        ],
      ),
    );
  }
}
