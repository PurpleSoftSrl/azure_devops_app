import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/search_field.dart';
import 'package:azure_devops/src/widgets/work_item_type_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FiltersRow extends StatelessWidget {
  const FiltersRow({
    required this.filters,
    required this.resetFilters,
    this.saveFilters,
  });

  final List<FilterMenu<Object?>> filters;
  final VoidCallback resetFilters;
  final VoidCallback? saveFilters;

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
              child: _FiltersActionsMenu(
                resetFilters: resetFilters,
                saveFilters: saveFilters,
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
    this.child,
    this.body,
    this.onSearchChanged,
    this.showLeading = true,
  })  : currentFilters = null,
        onSelectedMultiple = null,
        _isMultiple = false;

  const FilterMenu.custom({
    required this.body,
    required this.title,
    required this.currentFilter,
    this.formatLabel,
    required this.isDefaultFilter,
    this.child,
  })  : widgetBuilder = null,
        values = const [],
        onSelected = null,
        onSearchChanged = null,
        currentFilters = null,
        onSelectedMultiple = null,
        showLeading = true,
        _isMultiple = false;

  const FilterMenu.multiple({
    this.body,
    required this.title,
    this.formatLabel,
    required this.isDefaultFilter,
    this.child,
    required this.currentFilters,
    required this.onSelectedMultiple,
    required this.values,
    required this.widgetBuilder,
    this.onSearchChanged,
    this.showLeading = true,
  })  : onSelected = null,
        currentFilter = null,
        _isMultiple = true;

  final void Function(T)? onSelected;
  final List<T> values;
  final T? currentFilter;
  final Set<T>? currentFilters;
  final String title;
  final String Function(T)? formatLabel;
  final Widget Function(T)? widgetBuilder;
  final bool isDefaultFilter;
  final Widget? child;
  final Widget? body;
  final List<T> Function(String)? onSearchChanged;
  final void Function(Set<T> states)? onSelectedMultiple;
  final bool showLeading;

  final bool _isMultiple;

  @override
  Widget build(BuildContext context) {
    final chipLabel = switch (isDefaultFilter) {
      true => title,
      false when _isMultiple => currentFilters!.length > 1
          ? '$title - ${currentFilters!.length}'
          : formatLabel?.call(currentFilters!.single) ?? currentFilters!.single.toString(),
      _ => formatLabel?.call(currentFilter!) ?? currentFilter.toString(),
    };

    final chip = Chip(
      backgroundColor: isDefaultFilter ? null : context.colorScheme.primary,
      visualDensity: VisualDensity.compact,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              chipLabel,
              style: context.textTheme.bodySmall!.copyWith(color: context.themeExtension.onBackground, height: 1),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Icon(
            Icons.keyboard_arrow_down_outlined,
            color: context.themeExtension.onBackground,
          ),
        ],
      ),
    );

    return _FilterBottomsheet(
      title: title,
      values: values,
      formatLabel: formatLabel,
      onSelected: onSelected,
      widgetBuilder: widgetBuilder,
      currentFilter: currentFilter,
      customBody: body,
      onSearchChanged: onSearchChanged,
      isDefaultFilter: isDefaultFilter,
      currentFilters: currentFilters,
      onSelectedMultiple: onSelectedMultiple,
      showLeading: showLeading,
      isMultiple: _isMultiple,
      child: child ?? chip,
    );
  }
}

class _FilterBottomsheet<T> extends StatelessWidget {
  const _FilterBottomsheet({
    required this.title,
    required this.values,
    this.formatLabel,
    this.onSelected,
    required this.widgetBuilder,
    this.currentFilter,
    required this.child,
    this.customBody,
    this.onSearchChanged,
    required this.isDefaultFilter,
    this.currentFilters,
    this.onSelectedMultiple,
    required this.isMultiple,
    this.showLeading = true,
  }) : assert(!isMultiple || currentFilters != null, 'If [isMultiple] [currentFilters] must not be null');

  final String title;
  final List<T> values;
  final String Function(T)? formatLabel;
  final void Function(T)? onSelected;
  final Widget Function(T)? widgetBuilder;
  final T? currentFilter;
  final Set<T>? currentFilters;
  final Widget child;
  final Widget? customBody;
  final List<T> Function(String)? onSearchChanged;
  final bool isDefaultFilter;
  final void Function(Set<T>)? onSelectedMultiple;
  final bool isMultiple;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    const imageSize = 35.0;
    return InkWell(
      key: ValueKey(title),
      onTap: () {
        final allValues = [...values];
        final visibleValues = ValueNotifier([...values]);
        final isSearchable = onSearchChanged != null;

        if (isSearchable && !isDefaultFilter && !isMultiple) {
          final query = formatLabel?.call(currentFilter!) ?? '';
          visibleValues.value = onSearchChanged!.call(query);
        }

        final selectedValues = ValueNotifier(isMultiple ? {...currentFilters!} : <T>{});

        if (isMultiple) {
          final selectedVisibleValues = visibleValues.value.where((v) => selectedValues.value.contains(v));
          final nonSelectedVisibleValues = visibleValues.value.whereNot((v) => selectedValues.value.contains(v));
          visibleValues.value = [...selectedVisibleValues, ...nonSelectedVisibleValues];
        }

        OverlayService.bottomsheet(
          isScrollControlled: true,
          spaceUnderTitle: false,
          name: 'filter_$title',
          heightPercentage: isSearchable ? .9 : .8,
          builder: (context) =>
              customBody ??
              Column(
                children: [
                  if (isMultiple)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Toggle all'),
                          ValueListenableBuilder<Set<T>>(
                            valueListenable: selectedValues,
                            builder: (_, selectedVals, __) => Checkbox(
                              value: selectedVals.length >= values.length,
                              onChanged: (_) {
                                if (selectedVals.length >= values.length) {
                                  selectedValues.value = {};
                                } else {
                                  selectedValues.value = {...values};
                                }
                              },
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            height: 30,
                            child: TextButton(
                              style: Theme.of(context).textButtonTheme.style!.copyWith(
                                    backgroundColor: WidgetStatePropertyAll(context.colorScheme.primary),
                                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                  ),
                              onPressed: () {
                                onSelectedMultiple?.call(selectedValues.value);
                                AppRouter.popRoute();
                              },
                              child: Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      children: [
                        if (isSearchable)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DevOpsSearchField(
                              autofocus: false,
                              onChanged: (s) {
                                visibleValues.value = onSearchChanged!.call(s);
                              },
                              onResetSearch: () {
                                visibleValues.value = allValues;
                              },
                              hint: 'Search',
                              initialValue: isDefaultFilter || isMultiple ? null : formatLabel?.call(currentFilter!),
                            ),
                          ),
                        ValueListenableBuilder<Set<T>>(
                          valueListenable: selectedValues,
                          builder: (_, selectedVals, __) => ValueListenableBuilder(
                            valueListenable: visibleValues,
                            builder: (context, visibleValues, __) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: visibleValues
                                  .map(
                                    (v) => InkWell(
                                      key: ValueKey(formatLabel?.call(v) ?? v.toString()),
                                      onTap: () {
                                        if (isMultiple) return;

                                        onSelected!(v);
                                        AppRouter.popRoute();
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              if (showLeading) ...[
                                                SizedBox(
                                                  height: imageSize,
                                                  width: imageSize,
                                                  child: widgetBuilder?.call(v),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                              ],
                                              Expanded(child: Text(formatLabel?.call(v) ?? v.toString())),
                                              if (isMultiple) ...[
                                                Checkbox(
                                                  value: selectedVals.contains(v),
                                                  onChanged: (_) {
                                                    if (selectedVals.contains(v)) {
                                                      selectedValues.value.remove(v);
                                                    } else {
                                                      selectedValues.value.add(v);
                                                    }
                                                    selectedValues.value = {...selectedValues.value};
                                                  },
                                                ),
                                              ] else if (currentFilter == v) ...[
                                                Icon(DevOpsIcons.success),
                                              ],
                                            ],
                                          ),
                                          if (v != visibleValues.last)
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
                      ],
                    ),
                  ),
                ],
              ),
        );
      },
      child: child,
    );
  }
}

class _FiltersActionsMenu extends StatelessWidget {
  const _FiltersActionsMenu({
    required this.resetFilters,
    this.saveFilters,
    required this.selectedFiltersCount,
  });

  final VoidCallback resetFilters;
  final VoidCallback? saveFilters;
  final int selectedFiltersCount;

  @override
  Widget build(BuildContext context) {
    return DevOpsPopupMenu(
      tooltip: 'Reset or save filters',
      offset: const Offset(0, 20),
      items: () => [
        PopupItem(
          onTap: resetFilters,
          text: 'Reset filters',
          icon: DevOpsIcons.failed,
        ),
        if (saveFilters != null)
          PopupItem(
            onTap: saveFilters!,
            text: 'Save filters',
            icon: Icons.save_outlined,
          ),
      ],
      child: Chip(
        visualDensity: VisualDensity.compact,
        label: Row(
          children: [
            Icon(DevOpsIcons.filter),
            const SizedBox(
              width: 5,
            ),
            CircleAvatar(
              radius: 10,
              backgroundColor: context.themeExtension.onBackground,
              child: Text(
                selectedFiltersCount.toString(),
                style: context.textTheme.labelSmall!.copyWith(color: context.themeExtension.background, height: 1),
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
            userDescriptor: user.descriptor,
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
    final color = int.tryParse(state.color, radix: 16);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor:
            state == WorkItemState.all || color == null ? Colors.transparent : Color(color).withValues(alpha: 1),
      ),
    );
  }
}

class WorkItemStateCategoryFilterWidget extends StatelessWidget {
  const WorkItemStateCategoryFilterWidget({required this.category});

  final WorkItemStateCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: switch (category) {
          WorkItemStateCategory.proposed => Colors.grey,
          WorkItemStateCategory.inProgress => Colors.blue,
          WorkItemStateCategory.resolved => Colors.yellow,
          WorkItemStateCategory.completed => Colors.green,
          WorkItemStateCategory.removed => Colors.red,
        },
      ),
    );
  }
}

class ProjectFilterWidget extends StatelessWidget {
  const ProjectFilterWidget({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final api = context.api;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: project.defaultTeamImageUrl == null || api.isImageUnauthorized
          ? const SizedBox()
          : CachedNetworkImage(
              imageUrl: project.defaultTeamImageUrl!,
              httpHeaders: api.headers,
              errorWidget: (_, __, ___) => Icon(DevOpsIcons.project),
            ),
    );
  }
}

/// Used only to skip test work item types in a single point
class WorkItemTypeFilterMenu extends FilterMenu<WorkItemType> {
  WorkItemTypeFilterMenu({
    required super.title,
    required List<WorkItemType> values,
    required super.currentFilter,
    required super.onSelected,
    required super.isDefaultFilter,
    required super.widgetBuilder,
    super.formatLabel,
  }) : super(
          values: values.where((t) => !_typesToSkip.contains(t.name)).toList(),
        );

  WorkItemTypeFilterMenu.multiple({
    required super.title,
    required List<WorkItemType> values,
    required super.currentFilters,
    required super.onSelectedMultiple,
    required super.isDefaultFilter,
    required super.widgetBuilder,
    super.formatLabel,
  }) : super.multiple(
          values: values.where((t) => !_typesToSkip.contains(t.name)).toList(),
        );

  // skip test types to align with devops website
  static const _typesToSkip = ['Test Plan', 'Test Suite'];
}
