import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/widgets/empty_page.dart';
import 'package:azure_devops/src/widgets/error_page.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class AppPage<T extends Object?> extends StatefulWidget {
  const AppPage({
    super.key,
    this.builder,
    this.sliverBuilder,
    this.onEmpty,
    required this.init,
    this.onLoading,
    this.dispose,
    required this.title,
    this.notifier,
    this.actions,
    this.refreshController,
    this.safeAreaBottom = true,
    this.header,
    this.padding,
    this.showScrollbar = false,
    this.onResetFilters,
    this.fixedAppBar = false,
    this.showBackButton = true,
  }) : _isEmpty = false;

  const AppPage.empty({
    super.key,
    required this.builder,
    required this.init,
    this.dispose,
  })  : title = '',
        actions = null,
        header = null,
        notifier = null,
        onEmpty = null,
        onLoading = null,
        padding = null,
        refreshController = null,
        safeAreaBottom = true,
        showScrollbar = false,
        fixedAppBar = false,
        onResetFilters = null,
        showBackButton = true,
        sliverBuilder = null,
        _isEmpty = true;

  final Widget Function(T)? builder;
  final Widget Function(T)? sliverBuilder;
  final String? onEmpty;
  final Future<dynamic> Function() init;
  final Future<bool> Function()? onLoading;
  final VoidCallback? dispose;
  final String title;
  final List<Widget>? actions;
  final ValueNotifier<ApiResponse<T>?>? notifier;
  final RefreshController? refreshController;
  final bool safeAreaBottom;
  final Widget Function()? header;
  final EdgeInsets? padding;
  final bool showScrollbar;
  final VoidCallback? onResetFilters;
  final bool fixedAppBar;
  final bool showBackButton;

  final bool _isEmpty;

  @override
  State<AppPage<T>> createState() => _AppPageStateListenable<T>();
}

class _AppPageStateListenable<T> extends State<AppPage<T>> with AppLogger {
  late RefreshController _refreshController;
  late VoidCallback _onRefresh;
  late VoidCallback _onLoading;

  @override
  void initState() {
    super.initState();

    widget.init().onError(
      (e, s) {
        logDebug('Exception on init: $e');
        if (widget.notifier != null) {
          widget.notifier!.value = widget.notifier!.value?.copyWith(isError: true) ?? ApiResponse.error(null);
        }

        logError(e, s);
      },
    );

    _refreshController = widget.refreshController ?? RefreshController();
    _onRefresh = () async {
      try {
        await widget.init();
      } catch (e, s) {
        logDebug('Exception on refresh: $e');
        if (widget.notifier != null) {
          widget.notifier!.value = widget.notifier!.value?.copyWith(isError: true);
        }

        logError(e, s);
      }
      _refreshController.refreshCompleted();
    };

    _onLoading = () async {
      final res = await widget.onLoading?.call();
      if (res != null && !res) {
        // no more data
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    };
  }

  @override
  void dispose() {
    widget.dispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.builder != null || widget.sliverBuilder != null,
      'Either builder or sliverBuilder must be provided',
    );

    if (widget._isEmpty) {
      return widget.sliverBuilder?.call(null as T) ?? widget.builder!(null as T);
    }

    final actions = <Widget>[...widget.actions ?? [], if (widget.actions != null) const SizedBox(width: 4)];
    const paddingTop = 100.0;
    final scrollController = ScrollController();

    if (widget.notifier == null) {
      return Scaffold(
        body: SafeArea(
          bottom: widget.safeAreaBottom,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                title: Text(widget.title),
                floating: true,
                snap: true,
                surfaceTintColor: context.themeExtension.background,
                shadowColor: Colors.transparent,
                actions: actions,
                expandedHeight: 50,
                bottom: widget.header == null
                    ? null
                    : _Header(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            widget.header!(),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
              ),
              if (widget.header == null)
                SliverToBoxAdapter(
                  child: const SizedBox(
                    height: 20,
                  ),
                ),
              SliverPadding(
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
                sliver: widget.sliverBuilder?.call(null as T) ?? SliverToBoxAdapter(child: widget.builder!(null as T)),
              ),
              SliverToBoxAdapter(
                child: const SizedBox(
                  height: 40,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ValueListenableBuilder<ApiResponse<T?>?>(
        valueListenable: widget.notifier!,
        builder: (_, response, __) => Stack(
          alignment: Alignment.center,
          children: [
            SafeArea(
              bottom: widget.safeAreaBottom,
              child: Scrollbar(
                controller: scrollController,
                thickness: widget.showScrollbar ? null : 0,
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  enablePullUp: widget.onLoading != null,
                  footer: CustomFooter(
                    builder: (context, mode) {
                      var loadText = '';
                      switch (mode) {
                        case LoadStatus.canLoading:
                          loadText = 'Load more';
                        case LoadStatus.idle:
                          loadText = 'Idle';
                        case LoadStatus.loading:
                          loadText = 'Loading';
                        case LoadStatus.noMore:
                        case LoadStatus.failed:
                        default:
                          break;
                      }
                      return SizedBox(
                        height: 48,
                        child: Center(child: Text(loadText)),
                      );
                    },
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverAppBar(
                        title: Text(widget.title),
                        floating: true,
                        snap: true,
                        pinned: widget.fixedAppBar,
                        actions: actions,
                        surfaceTintColor: context.themeExtension.background,
                        scrolledUnderElevation: 0,
                        expandedHeight: 50,
                        automaticallyImplyLeading: widget.showBackButton,
                        bottom: widget.header == null
                            ? null
                            : _Header(
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    widget.header!(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      if (widget.header == null)
                        SliverToBoxAdapter(
                          child: const SizedBox(
                            height: 20,
                          ),
                        ),
                      if (response != null && response.isError)
                        SliverPadding(
                          padding: EdgeInsets.only(top: paddingTop),
                          sliver: SliverToBoxAdapter(
                            child: ErrorPage(
                              description: (response.errorResponse?.reasonPhrase?.isEmpty ?? true)
                                  ? 'Something went wrong'
                                  : response.errorResponse!.reasonPhrase!,
                              onRetry: widget.init,
                            ),
                          ),
                        )
                      else if (response != null &&
                          widget.onEmpty != null &&
                          (response.data is List) &&
                          (response.data as List).isEmpty)
                        SliverPadding(
                          padding: EdgeInsets.only(top: paddingTop),
                          sliver: SliverToBoxAdapter(
                            child: EmptyPage(widget: widget, onRefresh: _onRefresh),
                          ),
                        )
                      else if (response?.data != null)
                        SliverPadding(
                          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
                          sliver: widget.sliverBuilder?.call(widget.notifier!.value!.data!) ??
                              SliverToBoxAdapter(child: widget.builder!(widget.notifier!.value!.data!)),
                        ),
                      SliverToBoxAdapter(
                        child: const SizedBox(
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (response == null)
              Padding(
                padding: EdgeInsets.only(top: paddingTop),
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget implements PreferredSizeWidget {
  const _Header({required this.child});

  final Widget child;

  @override
  State<_Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 40);
}

class _HeaderState extends State<_Header> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
