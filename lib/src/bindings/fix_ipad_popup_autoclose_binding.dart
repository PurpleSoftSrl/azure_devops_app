import 'package:flutter/widgets.dart';

/// A Flutter binding that fixes the iPad popup menus auto-closing immediately issue.
/// See https://github.com/flutter/flutter/issues/175606 and https://github.com/flutter/flutter/issues/177992
class FixIpadPopupAutocloseFlutterBinding extends WidgetsFlutterBinding {
  @override
  void handlePointerEvent(PointerEvent event) {
    if (event.position == Offset.zero) {
      return;
    }
    super.handlePointerEvent(event);
  }
}
