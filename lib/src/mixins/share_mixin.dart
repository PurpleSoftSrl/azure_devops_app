import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

mixin ShareMixin {
  void shareUrl(String url) {
    final size = MediaQueryData.fromWindow(window).size;
    Share.share(
      url,
      sharePositionOrigin: Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width / 2,
        height: size.height / 2,
      ),
    );
  }
}
