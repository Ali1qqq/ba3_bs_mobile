import 'package:flutter/material.dart';

import '../../../features/floating_window/services/floating_window_service.dart';
import '../../utils/app_service_utils.dart';

mixin FloatingLauncher {
  /// Launches a floating window with a specified widget.
  void launchFloatingWindow({
    required BuildContext context,
    required Widget floatingScreen,
    String? tag,
    String? minimizedTitle,
    VoidCallback? onCloseCallback,
    double? defaultHeight,
    double? defaultWidth,
    bool? isResizing,
  }) {
    FloatingWindowService.launchFloatingWindow(
      context: context,
      tag: tag ?? AppServiceUtils.generateUniqueTag('FloatingWindowController'),
      onCloseCallback: onCloseCallback,
      floatingScreen: floatingScreen,
      minimizedTitle: minimizedTitle,
      defaultHeight: defaultHeight,
      defaultWidth: defaultWidth,
    );
  }
}