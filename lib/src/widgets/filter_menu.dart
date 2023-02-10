import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
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
  const FilterMenu.user({
    required this.title,
    required this.values,
    required this.currentFilter,
    required this.onSelected,
    this.formatLabel,
    required this.isDefaultFilter,
  }) : isUsers = true;

  const FilterMenu({
    required this.title,
    required this.values,
    required this.currentFilter,
    required this.onSelected,
    this.formatLabel,
    required this.isDefaultFilter,
  }) : isUsers = false;

  final void Function(T)? onSelected;
  final List<T> values;
  final T currentFilter;
  final String title;
  final String Function(T)? formatLabel;
  final bool isDefaultFilter;
  final bool isUsers;

  @override
  Widget build(BuildContext context) {
    final menu = Chip(
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      backgroundColor: isDefaultFilter ? null : context.colorScheme.primary,
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDefaultFilter ? title : (formatLabel?.call(currentFilter) ?? currentFilter.toString()),
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

    if (isUsers) {
      return InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => Container(
              height: context.height * .8,
              decoration: BoxDecoration(
                color: context.colorScheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: ListView(
                  children: values
                      .map(
                        (v) => InkWell(
                          onTap: () {
                            onSelected!(v);
                            AppRouter.popRoute();
                          },
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  if (v is GraphUser && (v.descriptor?.isNotEmpty ?? false))
                                    MemberAvatar(userDescriptor: v.descriptor!)
                                  else
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Icon(DevOpsIcons.users),
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
              ),
            ),
          );
        },
        child: menu,
      );
    }

    final children = values
        .map(
          (v) => PopupMenuItem<T>(
            key: ValueKey('Popup menu item ${formatLabel?.call(v) ?? v.toString()}'),
            value: v,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: v != values.last ? 15 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatLabel?.call(v) ?? v.toString(),
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      if (currentFilter == v) Icon(DevOpsIcons.success),
                    ],
                  ),
                ),
                if (v != values.last)
                  const Divider(
                    height: 0,
                    thickness: 1,
                  ),
              ],
            ),
          ),
        )
        .toList();

    return PopupMenuButton(
      key: ValueKey('Popup menu $title'),
      onSelected: onSelected,
      itemBuilder: (_) => children,
      elevation: 0,
      tooltip: 'Filter $title',
      offset: const Offset(0, 40),
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      child: menu,
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
      key: ValueKey('Popup menu reset filters'),
      onSelected: (_) => resetFilters(),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
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
