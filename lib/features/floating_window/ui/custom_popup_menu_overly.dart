import 'package:flutter/material.dart';

import '../managers/overlay_entry_with_priority_manager.dart';

void customPopupMenuOverlay<T>({
  required BuildContext context,
  required List<T> items,
  required Offset tapPosition,
  required String Function(T item) itemLabelBuilder,
  required VoidCallback back,
  required OverlayEntryWithPriorityManager overlayEntryWithPriorityInstance,
  required ValueChanged<T> onSelected,
  VoidCallback? onCloseCallback,
  int? priority,
}) {
  OverlayEntry? overlayEntry;

  Widget buildMenu() {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return InkWell(
            onTap: () {
              back();
              onSelected.call(item);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                itemLabelBuilder(item),
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  OverlayEntry createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              back();
            },
            child: Container(
              color: Colors.transparent, // Ensures the tap is registered but keeps it invisible
            ),
          ),
          Positioned(
            left: tapPosition.dx,
            top: tapPosition.dy,
            child: buildMenu(),
          ),
        ],
      ),
    );
  }

  final OverlayState overlay = Overlay.of(context);
  overlayEntry = createOverlayEntry();

  overlayEntryWithPriorityInstance.displayOverlay(
    overlay: overlay,
    overlayEntry: overlayEntry,
    priority: priority,
    onCloseCallback: () {
      onCloseCallback?.call();
      overlayEntry = null;
    },
  );
}
