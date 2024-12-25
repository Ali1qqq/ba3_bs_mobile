import 'package:flutter/material.dart';

import '../../../features/floating_window/services/floating_window_service.dart';

mixin FloatingLauncher {
  /// Launches a floating window with a specified widget.
  void launchFloatingWindow({
    required BuildContext context,
    required Widget floatingScreen,
    String? minimizedTitle,
    VoidCallback? onCloseCallback,
    double? defaultHeight,
    double? defaultWidth,
  }) {
    FloatingWindowService.launchFloatingWindow(
      context: context,
      onCloseCallback: onCloseCallback,
      floatingScreen: floatingScreen,
      minimizedTitle: minimizedTitle,
      defaultHeight: defaultHeight,
      defaultWidth: defaultWidth,
    );
  }
}
