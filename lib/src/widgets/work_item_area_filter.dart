import 'package:azure_devops/src/extensions/area_or_iteration_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/areas_and_iterations.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AreaFilterBody extends StatelessWidget {
  const AreaFilterBody({
    required this.areasToShow,
    required this.currentFilter,
    required this.onTap,
  });

  final Iterable<AreaOrIteration> areasToShow;
  final AreaOrIteration? currentFilter;
  final void Function(AreaOrIteration?) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProjectAreas(
            area: AreaOrIteration.all(),
            currentFilter: currentFilter,
            onTap: (a) {
              AppRouter.popRoute();
              onTap(null); // reset area filter
            },
          ),
        ),
        ...areasToShow.sortedBy((a) => a.path.toLowerCase()).map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProjectAreas(
                  area: a,
                  currentFilter: currentFilter,
                  onTap: (a) {
                    AppRouter.popRoute();
                    onTap(a);
                  },
                ),
              ),
            ),
      ],
    );
  }
}

class ProjectAreas extends StatelessWidget {
  const ProjectAreas({required this.area, required this.onTap, this.currentFilter});

  final AreaOrIteration area;
  final AreaOrIteration? currentFilter;
  final void Function(AreaOrIteration) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onTap(area),
          child: Row(
            children: [
              CircleAvatar(
                radius: 2.5,
                backgroundColor: context.colorScheme.onBackground,
              ),
              const SizedBox(width: 8),
              Text(area.name),
              if (currentFilter != null && (currentFilter!.escapedAreaPath == area.escapedAreaPath)) ...[
                const Spacer(),
                Icon(DevOpsIcons.success),
              ],
            ],
          ),
        ),
        const Divider(),
        ...(area.children ?? []).map(
          (c) => Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ProjectAreas(
              area: c,
              onTap: onTap,
              currentFilter: currentFilter,
            ),
          ),
        ),
      ],
    );
  }
}
