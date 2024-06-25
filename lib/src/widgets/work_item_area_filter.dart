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
    this.showActive = false,
    this.showAllFilter = true,
  });

  final Iterable<AreaOrIteration> areasToShow;
  final AreaOrIteration? currentFilter;
  final void Function(AreaOrIteration?) onTap;
  final bool showActive;
  final bool showAllFilter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (showAllFilter) ...[
          ProjectAreas(
            area: AreaOrIteration.all(),
            currentFilter: currentFilter,
            onTap: (a) {
              AppRouter.popRoute();
              onTap(null); // reset area filter
            },
            showActive: showActive,
          ),
          const SizedBox(
            height: 16,
          ),
        ],
        ...areasToShow.sortedBy((a) => a.path.toLowerCase()).map(
              (a) => ProjectAreas(
                area: a,
                currentFilter: currentFilter,
                onTap: (a) {
                  AppRouter.popRoute();
                  onTap(a);
                },
                showActive: showActive,
              ),
            ),
      ],
    );
  }
}

class ProjectAreas extends StatelessWidget {
  const ProjectAreas({required this.area, required this.onTap, this.currentFilter, required this.showActive});

  final AreaOrIteration area;
  final AreaOrIteration? currentFilter;
  final void Function(AreaOrIteration) onTap;
  final bool showActive;

  @override
  Widget build(BuildContext context) {
    if (showActive && area.name != AreaOrIteration.all().name) {
      final isActive = area.isActive;
      final hasActiveChildren = area.children != null && area.children!.any((a) => a.isActive);

      if (!isActive && !hasActiveChildren) return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onTap(area),
          child: Row(
            children: [
              CircleAvatar(
                radius: 2.5,
                backgroundColor: context.themeExtension.onBackground,
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
            padding: EdgeInsets.only(left: 16, bottom: c == area.children!.last ? 16 : 0),
            child: ProjectAreas(
              area: c,
              onTap: onTap,
              currentFilter: currentFilter,
              showActive: showActive,
            ),
          ),
        ),
      ],
    );
  }
}
