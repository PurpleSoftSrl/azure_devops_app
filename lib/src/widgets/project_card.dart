import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.height,
    required this.project,
    required this.onTap,
  });

  final double? height;
  final Project project;
  final void Function(Project p) onTap;

  @override
  Widget build(BuildContext context) {
    final api = context.api;
    return SizedBox(
      height: height,
      child: NavigationButton(
        margin: const EdgeInsets.only(top: 8),
        inkwellKey: ValueKey(project.name),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        onTap: () => onTap(project),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: api.isImageUnauthorized
                  ? SizedBox(
                      height: 30,
                      width: 30,
                      child: Icon(DevOpsIcons.project),
                    )
                  : CachedNetworkImage(
                      imageUrl: project.defaultTeamImageUrl!,
                      httpHeaders: api.headers,
                      errorWidget: (_, __, ___) => Icon(DevOpsIcons.project),
                      width: 30,
                      height: 30,
                    ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(child: Text(project.name!)),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
