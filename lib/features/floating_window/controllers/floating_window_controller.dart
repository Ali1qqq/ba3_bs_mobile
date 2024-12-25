import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/features/floating_window/managers/window_position_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/debounce.dart';
import '../managers/overly_manager.dart';
import '../managers/resize_manager.dart';
import '../mixins/cursor_update_mixin.dart';

class FloatingWindowController extends GetxController with CursorUpdateMixin {
  // Get the singleton instance of WindowPositionManager
  WindowPositionManager windowPositionManager = WindowPositionManager.instance;

  FloatingWindowController({double? defaultWidth, double? defaultHeight}) {
    log('call FloatingWindowController constructor');

    defaultWidthRatio = defaultWidth != null ? defaultWidth / 1.sw : 0.7;
    defaultHeightRatio = defaultHeight != null ? defaultHeight / 1.sh : 0.85;

    _initializeWindow(defaultHeight: defaultHeight, defaultWidth: defaultWidth);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,

    ]);
  }

  final ResizeManager resizeManager = ResizeManager(edgeSize: 8.0);

  final OverlayManager overlayManager = OverlayManager();

  late double x, y, width, height;

  final double minWidth = 700.0, minHeight = 600.0;

  final parentSize = Rx<Size>(Size.zero);

  final GlobalKey floatingWindowKey = GlobalKey();

  Offset? resizeStartPosition;

  bool isResizing = false;

  final Rx<SystemMouseCursor> mouseCursor = SystemMouseCursors.basic.obs;

  double bottomWindowWidthRatio = AppConstants.bottomWindowWidth / AppConstants.deviceFullWidth;

  double bottomWindowHeightRatio = AppConstants.bottomWindowHeight / AppConstants.deviceFullHeight;

  // New State to Handle Minimized State
  bool isMinimized = false;

  final Debounce _resizeDebounce = Debounce();
  final Debounce _windowSizeChangeDebounce = Debounce();

  late double defaultWidthRatio;
  late double defaultHeightRatio;

  void _initializeWindow({double? defaultWidth, double? defaultHeight}) {
    const double minWidthRatio = 1;
    const double minHeightRatio = 1;


    final double adjustedWidthRatio = defaultWidthRatio < minWidthRatio ? minWidthRatio : defaultWidthRatio;
    final double adjustedHeightRatio = defaultHeightRatio < minHeightRatio ? minHeightRatio : defaultHeightRatio;

    width = adjustedWidthRatio.sw;
    height = adjustedHeightRatio.sh;

    x = (1.sw - width) / 2;
    y = (1.sh - height) / 2;

    parentSize.value = Size(1.sw, 1.sh);
  }

  Offset initWindowPositionManager() {
    final double windowWidth = bottomWindowWidthRatio * parentSize.value.width; // Width for the minimized container
    final double windowHeight = bottomWindowHeightRatio * parentSize.value.height; // Height for the minimized container

    final targetPositionRatio = windowPositionManager.getNextWindowPositionRatio(
        windowWidth, windowHeight, parentSize.value.width, parentSize.value.height);

    return targetPositionRatio;
  }

  void updateWindowForSizeChange({
    required Size newParentSize,
    required Offset positionRatio,
  }) {
    // Determine the debounce duration based on whether the window is minimized or maximized
    final debounceDuration = isMinimized ? const Duration(milliseconds: 80) : const Duration(milliseconds: 150);

    // Debounced window size change logic
    _windowSizeChangeDebounce.call(
      duration: debounceDuration,
      action: () {
        if (isMinimized) {
          _updateMinimizedState(newParentSize, positionRatio);
        } else {
          _updateMaximizedState(newParentSize);
        }

        // Update the parent size and refresh the UI
        parentSize.value = newParentSize;
        update();
      },
    );
  }

  void _updateMaximizedState(Size newParentSize) {
    const double minWidthRatio = 1;
    const double minHeightRatio = 1;

    final double adjustedWidthRatio = defaultWidthRatio < minWidthRatio ? minWidthRatio : defaultWidthRatio;
    final double adjustedHeightRatio = defaultHeightRatio < minHeightRatio ? minHeightRatio : defaultHeightRatio;

    width = newParentSize.width * adjustedWidthRatio;
    height = newParentSize.height * adjustedHeightRatio;

    x = (newParentSize.width - width) / 2;
    y = (newParentSize.height - height) / 2;

    log('Parent size updated -> Width: ${newParentSize.width}, Height: ${newParentSize.height}');
  }

  void _updateMinimizedState(Size newParentSize, Offset positionRatio) {
    width = bottomWindowWidthRatio * newParentSize.width; // Width for the minimized container
    height = bottomWindowHeightRatio * newParentSize.height; // Height for the minimized container

    x = positionRatio.dx * newParentSize.width;
    y = positionRatio.dy * newParentSize.height;

    log('newParentSize width on updateForParentSizeChange: ${newParentSize.width}');
    log('newParentSize height on updateForParentSizeChange: ${newParentSize.height}');
  }

  /// Resize to 95% of the parent container
  void maximize() {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,

    ]);
    width = parentSize.value.width ;
    height = parentSize.value.height;

    // Ensure the window stays within bounds
    x = x.clamp(0, parentSize.value.width - width);
    y = y.clamp(0, parentSize.value.height - height);

    update();
  }

  /// Resize to the minimum allowed size
  void resizeToMin() {
    width = minWidth;
    height = minHeight;

    // Ensure the window stays within bounds
    x = x.clamp(0, parentSize.value.width - width);
    y = y.clamp(0, parentSize.value.height - height);

    update();
  }

  void minimize(Offset position) {
    isMinimized = true;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

    ]);
    width = bottomWindowWidthRatio * parentSize.value.width; // Width for the minimized container
    height = bottomWindowHeightRatio * parentSize.value.height; // Height for the minimized container

    x = position.dx * parentSize.value.width;
    y = position.dy * parentSize.value.height;

    update();
  }

  void restoreWindowFromMinimized() {
    isMinimized = false;
    _initializeWindow();
    update();
  }

  void maximizeWindowFromMinimized() {
    isMinimized = false;
    maximize();
    update();
  }

  void displayFloatingWindow(
      {required BuildContext context,
      required Widget floatingScreen,
      required Offset targetPositionRatio,
      required String tag,
      String? minimizedTitle,
      VoidCallback? onCloseCallback}) {
    final overlay = Overlay.of(context);

    overlayManager.displayOverlay(
      overlay: overlay,
      tag: tag,
      windowPositionManager: windowPositionManager,
      floatingScreen: floatingScreen,
      targetPositionRatio: targetPositionRatio,
      onCloseCallback: onCloseCallback,
      minimizedTitle: minimizedTitle,
    );
  }

  void move(DragUpdateDetails details, double screenWidth, double screenHeight) {
    x += details.delta.dx;
    y += details.delta.dy;

    x = x.clamp(0, screenWidth - width);
    y = y.clamp(0, screenHeight - height);

    update();
  }

  void resize(DragUpdateDetails details, double screenWidth, double screenHeight) {
    // Immediate visual update
    _applyResizeLogic(details, screenWidth, screenHeight);
    update();

    // Debounced constraints enforcement
    _resizeDebounce.call(
      duration: const Duration(milliseconds: 100),
      action: () {
        _applyConstraints(screenWidth, screenHeight);
        update();
      },
    );
  }

  void _applyResizeLogic(DragUpdateDetails details, double screenWidth, double screenHeight) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    if (resizeStartPosition == null) return;

    if (resizeManager.isOnLeftEdge(resizeStartPosition!)) {
      final newWidth = width - dx;
      if (newWidth >= minWidth && newWidth <= screenWidth * .95) {
        width = newWidth;
        x += dx;
      }
    }
    if (resizeManager.isOnRightEdge(details.localPosition, width) &&
        !resizeManager.isOnLeftEdge(resizeStartPosition!)) {
      final newWidth = width + dx;
      if (newWidth >= minWidth && newWidth <= screenWidth * .95) {
        width = newWidth;
      }
    }
    if (resizeManager.isOnTopEdge(resizeStartPosition!)) {
      final newHeight = height - dy;
      if (newHeight >= minHeight && newHeight <= screenHeight * .95) {
        height = newHeight;
        y += dy;
      }
    }
    if (resizeManager.isOnBottomEdge(details.localPosition, height) &&
        !resizeManager.isOnTopEdge(resizeStartPosition!)) {
      final newHeight = height + dy;
      if (newHeight >= minHeight && newHeight <= screenHeight * .95) {
        height = newHeight;
      }
    }
  }

  void _applyConstraints(double screenWidth, double screenHeight) {
    width = width.clamp(minWidth, screenWidth - x);
    height = height.clamp(minHeight, screenHeight - y);
    x = x.clamp(0, screenWidth - width);
    y = y.clamp(0, screenHeight - height);
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (isResizing) {
      resize(details, parentSize.value.width, parentSize.value.height);
    } else {
      move(details, parentSize.value.width, parentSize.value.height);
    }
  }

  void onPanStart(DragStartDetails details) {
    final Offset localPosition =
        getLocalPosition(floatingWindowKey: floatingWindowKey, globalPosition: details.globalPosition);

    if (resizeManager.isOnEdge(localPosition, width, height)) {
      isResizing = true;
      resizeStartPosition = localPosition;
    } else {
      isResizing = false;
    }
  }

  void onPanEnd(DragEndDetails details) {
    isResizing = false;
    resizeStartPosition = null;
  }

  void onHover(PointerHoverEvent event) => updateCursor(
        globalPosition: event.position,
        floatingWindowKey: floatingWindowKey,
        resizeManager: resizeManager,
        floatingWindowController: this,
        width: width,
        height: height,
      );
}
