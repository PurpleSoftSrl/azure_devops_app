import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/work_item_type_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FiltersRow extends StatelessWidget {
  const FiltersRow({
    required this.filters,
    required this.resetFilters,
  });

  final List<FilterMenu<Object?>> filters;
  final VoidCallback resetFilters;

  @override
  Widget build(BuildContext context) {
    final selectedFilters = filters.where((f) => !f.isDefaultFilter);
    final hasSelectedFilters = selectedFilters.isNotEmpty;
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (hasSelectedFilters)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _ResetFiltersMenu(
                resetFilters: resetFilters,
                selectedFiltersCount: selectedFilters.length,
              ),
            ),
          ...filters.map(
            (filter) => Padding(
              padding: EdgeInsets.only(
                left: !hasSelectedFilters && filter == filters.first ? 16 : 8,
                right: filter == filters.last ? 16 : 0,
              ),
              child: filter,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterMenu<T> extends StatelessWidget {
  const FilterMenu({
    required this.title,
    required this.values,
    required this.currentFilter,
    required this.onSelected,
    this.formatLabel,
    required this.isDefaultFilter,
    required this.widgetBuilder,
  }) : isUser = false;

  final void Function(T)? onSelected;
  final List<T> values;
  final T currentFilter;
  final String title;
  final String Function(T)? formatLabel;
  final Widget Function(T) widgetBuilder;
  final bool isDefaultFilter;

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final chip = Chip(
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      backgroundColor: isDefaultFilter ? null : context.colorScheme.primary,
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDefaultFilter ? title : (formatLabel?.call(currentFilter!) ?? currentFilter.toString()),
              style: context.textTheme.bodySmall!.copyWith(color: context.colorScheme.onBackground, height: 1),
            ),
            const SizedBox(
              width: 4,
            ),
            Icon(
              Icons.keyboard_arrow_down_outlined,
              color: context.colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );

    const imageSize = 35.0;
    return InkWell(
      key: ValueKey(title),
      onTap: () {
        OverlayService.bottomsheet(
          isScrollControlled: true,
          spaceUnderTitle: false,
          builder: (context) => ListView(
            children: values
                .map(
                  (v) => InkWell(
                    key: ValueKey(formatLabel?.call(v) ?? v.toString()),
                    onTap: () {
                      onSelected!(v);
                      AppRouter.popRoute();
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: imageSize,
                              width: imageSize,
                              child: widgetBuilder.call(v),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(formatLabel?.call(v) ?? v.toString()),
                            if (currentFilter == v) ...[
                              const Spacer(),
                              Icon(DevOpsIcons.success),
                            ],
                          ],
                        ),
                        if (v != values.last)
                          const Divider(
                            height: 20,
                          ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
      child: chip,
    );
  }
}

class _ResetFiltersMenu extends StatelessWidget {
  const _ResetFiltersMenu({required this.resetFilters, required this.selectedFiltersCount});

  final VoidCallback resetFilters;
  final int selectedFiltersCount;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      key: ValueKey('popup_menu_reset_filters'),
      onSelected: (_) => resetFilters(),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          key: ValueKey('reset_filters'),
          value: false,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reset filters',
                style: context.textTheme.titleSmall,
              ),
              Icon(DevOpsIcons.failed),
            ],
          ),
        ),
      ],
      elevation: 0,
      tooltip: 'Reset filters',
      offset: const Offset(0, 40),
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      child: Chip(
        label: Row(
          children: [
            Icon(DevOpsIcons.filter),
            const SizedBox(
              width: 5,
            ),
            CircleAvatar(
              radius: 10,
              backgroundColor: context.colorScheme.onBackground,
              child: Text(
                selectedFiltersCount.toString(),
                style: context.textTheme.labelSmall!.copyWith(color: context.colorScheme.background, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserFilterWidget extends StatelessWidget {
  const UserFilterWidget({required this.user});

  final GraphUser user;

  @override
  Widget build(BuildContext context) {
    return user.descriptor == null
        ? const SizedBox()
        : MemberAvatar(
            userDescriptor: user.descriptor!,
          );
  }
}

class WorkItemTypeFilter extends StatelessWidget {
  const WorkItemTypeFilter({required this.type});

  final WorkItemType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: WorkItemTypeIcon(type: type),
    );
  }
}

class WorkItemStateFilterWidget extends StatelessWidget {
  const WorkItemStateFilterWidget({required this.state});

  final WorkItemState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor:
            state == WorkItemState.all ? Colors.transparent : Color(int.parse(state.color, radix: 16)).withOpacity(1),
      ),
    );
  }
}

class ProjectFilterWidget extends StatelessWidget {
  const ProjectFilterWidget({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: project.defaultTeamImageUrl == null || apiService.isImageUnauthorized
          ? const SizedBox()
          : CachedNetworkImage(
              imageUrl: project.defaultTeamImageUrl!,
              httpHeaders: apiService.headers,
              errorWidget: (_, __, ___) => Icon(DevOpsIcons.project),
            ),
    );
  }
}
