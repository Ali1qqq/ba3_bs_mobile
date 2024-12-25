import 'package:flutter/material.dart';

import '../models/overlay_entry_with_priority.dart';

class OverlayEntryWithPriorityManager {
  /// Private constructor to prevent external instantiation.
  OverlayEntryWithPriorityManager._();

  /// The singleton instance of the manager.
  static final OverlayEntryWithPriorityManager instance = OverlayEntryWithPriorityManager._();

  /// Stores overlay entries; lower priority numbers indicate higher importance.
  final List<OverlayEntryWithPriority> _overlayEntries = [];

  late OverlayEntry _overlayEntry;
  late OverlayEntryWithPriority _overlayEntryWithPriority;
  VoidCallback? _onCloseCallback;

  /// Displays an overlay with priority management.
  ///
  /// This method shows a customizable overlay with content, an optional title, and size.
  /// The `onCloseCallback` is triggered when the overlay is dismissed, allowing actions
  /// after it is closed. The overlay can be dismissed by tapping the background, which will
  /// trigger the `onTap` handler and call `_removeOverlay()`, ultimately invoking the callback.
  ///
  /// Parameters:
  /// - `overlay`: The `OverlayState` to insert the overlay into.
  /// - `content`: The content widget for the overlay.
  /// - `title`: An optional title to display at the top.
  /// - `width`: Optional width of the overlay.
  /// - `height`: Optional height of the overlay.
  /// - `priority`: Optional priority, where lower values are higher priority.
  /// - `onCloseCallback`: A callback invoked after the overlay is closed.

  void displayOverlay({
    required OverlayState overlay,
    bool? showDivider,
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
    Alignment? overlayAlignment,
    Widget? content,
    OverlayEntry? overlayEntry,
    String? title,
    double? width,
    double? height,
    int? priority,
    VoidCallback? onCloseCallback,
  }) {
    if (hasHigherPriorityOverlay()) {
      _removeOverlay();
    }

    _onCloseCallback = onCloseCallback;

    // Create a new overlay entry if none is passed
    _overlayEntry = overlayEntry ??
        OverlayEntry(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                _removeOverlay();
              },
              child: Material(
                color: Colors.transparent,
                elevation: 8,
                borderRadius: borderRadius ?? BorderRadius.circular(24),
                child: Align(
                  alignment: overlayAlignment ?? Alignment.center,
                  child: Container(
                    width: width ?? 500,
                    height: height ?? 500,
                    padding: contentPadding ?? const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: borderRadius ?? BorderRadius.circular(24)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // Position elements top and bottom
                      children: [
                        // Header with Close Button
                        if (title != null)
                          Column(
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                              ),
                              if (showDivider ?? true) const Divider(),
                            ],
                          ),

                        // Content Area
                        Expanded(child: content ?? const Text('Content shown here')),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );

    _overlayEntryWithPriority = OverlayEntryWithPriority(
      overlayEntry: _overlayEntry,
      priority: priority ?? 0,
    );

    // Add overlay entry with priority
    _addOverlayEntryWithPriority();

    // Insert overlay entry into the overlay
    overlay.insert(_overlayEntry);
  }

  /// Adds an overlay entry with a specified priority.
  void _addOverlayEntryWithPriority() {
    _overlayEntries.add(_overlayEntryWithPriority);
  }

  /// Removes the current overlay entry.
  void _removeOverlay() {
    _overlayEntry.remove();
    _overlayEntries.remove(_overlayEntryWithPriority);
    _onCloseCallback?.call();
  }

  /// Manually removes the overlay.
  /// For example, use this when the user selects an item in the dialog to dismissed it.
  void dispose() {
    _removeOverlay();
  }

  /// Checks if any overlay exists with a priority higher than the given [defaultPriority].
  /// Lower numbers indicate higher priority (e.g., 0 is higher than 1).
  bool hasHigherPriorityOverlay([int defaultPriority = 1]) =>
      _overlayEntries.any((entry) => entry.priority < defaultPriority);

  void clearAllHigherPriorityOverlay() {
    if (hasHigherPriorityOverlay()) {
      _removeOverlay();
    }
  }
}
