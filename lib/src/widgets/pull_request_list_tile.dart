import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:flutter/material.dart';

class PullRequestListTile extends StatelessWidget {
  const PullRequestListTile({super.key, required this.onTap, required this.pr, required this.isLast});

  final VoidCallback onTap;
  final PullRequest pr;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodySmall!;
    return InkWell(
      key: ValueKey('pr_${pr.pullRequestId}'),
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(pr.title, overflow: TextOverflow.ellipsis, style: context.textTheme.labelLarge),
                ),
                const SizedBox(width: 10),
                Text(
                  pr.isDraft && pr.status != PullRequestStatus.abandoned ? 'Draft' : pr.status.toString(),
                  style: subtitleStyle.copyWith(color: pr.status.color),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text('!${pr.pullRequestId} ${pr.createdBy.displayName}', style: subtitleStyle),
                    Text(' in ', style: subtitleStyle.copyWith(color: context.colorScheme.onSecondary)),
                    Expanded(
                      child: Text(pr.repository.name, style: subtitleStyle, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 10),
                    Text(pr.creationDate.minutesAgo, style: subtitleStyle),
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
