import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_service_utils.dart';
import '../controllers/floating_window_controller.dart';

/// Service class to initializing and displaying floating windows.
class FloatingWindowService {
  /// Launches a floating window with the provided content.

  static void launchFloatingWindow({
    required BuildContext context,
    required Widget floatingScreen,
    String? minimizedTitle,
    VoidCallback? onCloseCallback,
    double? defaultWidth,
    double? defaultHeight,
  }) {
    final String tag = AppServiceUtils.generateUniqueTag('FloatingWindowController');

    // Initialize the floating window controller
    FloatingWindowController floatingWindowController =
        _initializeFloatingWindowController(defaultWidth: defaultWidth, defaultHeight: defaultHeight, tag: tag);

    // Get the initial target position for the floating window
    Offset targetPositionRatio = floatingWindowController.initWindowPositionManager();

    // Display the floating window
    floatingWindowController.displayFloatingWindow(
      context: context,
      tag: tag,
      floatingScreen: floatingScreen,
      targetPositionRatio: targetPositionRatio,
      onCloseCallback: onCloseCallback,
      minimizedTitle: minimizedTitle,
    );
  }

  /// Initializes and returns a new instance of [FloatingWindowController].
  static FloatingWindowController _initializeFloatingWindowController(
      {double? defaultWidth, double? defaultHeight, String? tag}) {
    // Create the controller if not already created

    if (!Get.isRegistered<FloatingWindowController>(tag: tag)) {
      Get.create(() => FloatingWindowController(defaultWidth: defaultWidth, defaultHeight: defaultHeight),
          tag: tag, permanent: false);
    }

    // Return the controller instance
    return Get.find<FloatingWindowController>(tag: tag);
  }
}
