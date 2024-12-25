import 'package:ba3_bs_mobile/features/floating_window/controllers/floating_window_controller.dart';
import 'package:flutter/cupertino.dart';

import '../managers/resize_manager.dart';

mixin CursorUpdateMixin {
  void updateCursor({
    required GlobalKey floatingWindowKey,
    required Offset globalPosition,
    required ResizeManager resizeManager,
    required FloatingWindowController floatingWindowController,
    required double width,
    required double height,
  }) {
    final Offset position = getLocalPosition(
        floatingWindowKey: floatingWindowKey, globalPosition: globalPosition);

    if (resizeManager.isOnTopLeftCorner(position) ||
        resizeManager.isOnBottomRightCorner(position, width, height)) {
      floatingWindowController.mouseCursor.value =
          SystemMouseCursors.resizeUpLeftDownRight;
    } else if (resizeManager.isOnTopRightCorner(position, width) ||
        resizeManager.isOnBottomLeftCorner(position, height)) {
      floatingWindowController.mouseCursor.value =
          SystemMouseCursors.resizeUpRightDownLeft;
    } else if (resizeManager.isOnLeftEdge(position) ||
        resizeManager.isOnRightEdge(position, width)) {
      floatingWindowController.mouseCursor.value =
          SystemMouseCursors.resizeLeftRight;
    } else if (resizeManager.isOnTopEdge(position) ||
        resizeManager.isOnBottomEdge(position, height)) {
      floatingWindowController.mouseCursor.value =
          SystemMouseCursors.resizeUpDown;
    } else {
      floatingWindowController.mouseCursor.value = SystemMouseCursors.basic;
    }
  }

  Offset getLocalPosition(
      {required GlobalKey floatingWindowKey, required Offset globalPosition}) {
    final RenderBox renderBox =
        floatingWindowKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }
}
