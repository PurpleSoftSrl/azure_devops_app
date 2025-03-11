import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_result_extension.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:flutter/material.dart';

class PipelineListTile extends StatelessWidget {
  const PipelineListTile({
    super.key,
    required this.onTap,
    required this.pipe,
    required this.isLast,
  });

  final VoidCallback onTap;
  final Pipeline pipe;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodySmall!;
    final isCustomPipelineName = pipe.definition?.name != null && pipe.definition!.name! != pipe.repository?.name;

    return InkWell(
      onTap: onTap,
      key: ValueKey('pipeline_${pipe.id}'),
      child: Column(
        children: [
          Row(
            children: [
              if (pipe.status == PipelineStatus.inProgress && pipe.approvals.isNotEmpty)
                Icon(
                  Icons.warning,
                  color: Colors.yellow,
                )
              else
                pipe.status == PipelineStatus.completed ? pipe.result.icon : pipe.status.icon,
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pipe.triggerInfo?.ciMessage ?? pipe.reason ?? '',
                      style: context.textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          pipe.requestedFor?.displayName ?? '',
                          style: subtitleStyle,
                        ),
                        Text(
                          ' in ',
                          style: subtitleStyle.copyWith(color: context.colorScheme.onSecondary),
                        ),
                        Expanded(
                          child: Text(
                            pipe.repository?.name ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle,
                          ),
                        ),
                      ],
                    ),
                    if (isCustomPipelineName) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        pipe.definition!.name!,
                        style: subtitleStyle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                pipe.startTime?.minutesAgo ?? '',
                style: subtitleStyle,
              ),
            ],
          ),
          if (!isLast)
            AppLayoutBuilder(
              smartphone: Divider(height: 24, thickness: 1),
              tablet: Divider(height: 48, thickness: 1),
            ),
        ],
      ),
    );
  }
}
