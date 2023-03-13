
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LifecycleListener extends StatefulWidget {
  const LifecycleListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<LifecycleListener> createState() => _LifecycleListenerState();
}

class _LifecycleListenerState extends State<LifecycleListener> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Sentry.captureMessage('App closed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
