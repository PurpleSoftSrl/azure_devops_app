import 'package:azure_devops/src/theme/theme.dart';
import 'package:flutter/material.dart';

class AppBasePage<T> extends StatefulWidget {
  const AppBasePage({required this.initState, required this.smartphone, required this.tablet});

  final T Function() initState;
  final Widget Function(T) smartphone;
  final Widget Function(T) tablet;

  @override
  State<AppBasePage<T>> createState() => _AppBasePageState<T>();
}

class _AppBasePageState<T> extends State<AppBasePage<T>> {
  late T _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      smartphone: widget.smartphone(_ctrl),
      tablet: widget.tablet(_ctrl),
    );
  }
}

class AppLayoutBuilder extends StatelessWidget {
  const AppLayoutBuilder({required this.smartphone, required this.tablet});

  final Widget smartphone;
  final Widget tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth < AppTheme.tabletBreakpoint ? smartphone : tablet,
    );
  }
}
