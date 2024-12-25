import 'package:flutter/material.dart';

/// Represents an overlay entry with a priority to determine its order in the overlay stack.
class OverlayEntryWithPriority {
  final OverlayEntry overlayEntry;
  final int priority;

  /// Priority of the overlay entry: `0` is the highest, `1` is default, and higher numbers are lower priority.
  OverlayEntryWithPriority({
    required this.overlayEntry,
    this.priority = 1,
  });
}
