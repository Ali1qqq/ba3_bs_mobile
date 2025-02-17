import 'package:ba3_bs_mobile/features/floating_window/managers/window_position_manager.dart';
import 'package:flutter/material.dart';

import '../ui/draggable_floating_window.dart';
import 'overlay_entry_with_priority_manager.dart';

class OverlayManager {
  void displayOverlay({
    required OverlayState overlay,
    required WindowPositionManager windowPositionManager,
    required Widget floatingScreen,
    required Offset targetPositionRatio,
    required String tag,
    String? minimizedTitle,
    VoidCallback? onCloseCallback,
  }) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return DraggableFloatingWindow(
          onBringToTop: () {
            // Check if any high-priority dialog or overlay is on top
            bool hasHigherPriorityOverlay = OverlayEntryWithPriorityManager.instance.hasHigherPriorityOverlay();

            // Bring this floating window to the top only if no higher-priority overlays exist
            if (!hasHigherPriorityOverlay) {
              overlayEntry.remove();
              overlay.insert(overlayEntry);
            }
          },
          onClose: () {
            overlayEntry.remove();
            windowPositionManager.removeWindowPosition(targetPositionRatio);

            onCloseCallback?.call();
          },
          targetPositionRatio: targetPositionRatio,
          floatingWindowContent: floatingScreen,
          tag: tag,
          minimizedTitle: minimizedTitle,
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}