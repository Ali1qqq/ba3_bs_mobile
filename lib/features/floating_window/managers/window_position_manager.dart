import 'dart:ui';

/// Manages window positions as ratios relative to the parent window dimensions.
class WindowPositionManager {
  /// Padding for vertical space between windows.
  static const double verticalPadding = 10.0;

  /// Padding for horizontal space between windows.
  static const double horizontalPadding = 10.0;

  /// Padding to prevent horizontal overflow of windows.
  static const double horizontalBoundaryPadding = 20.0;

  /// Private constructor to prevent external instantiation.
  WindowPositionManager._();

  /// Singleton instance of the WindowPositionManager.
  static final WindowPositionManager instance = WindowPositionManager._();

  /// List of window positions stored as ratios of the parent dimensions.
  List<Offset> windowPositionRatios = [];

  /// Calculates and returns the next available position for a new window,
  /// based on the parent window's dimensions.
  /// The position is returned as a ratio of the parent's width and height.
  Offset getNextWindowPositionRatio(double windowWidth, double windowHeight, double parentWidth, double parentHeight) {
    // If no previous positions exist, set the initial position.
    if (windowPositionRatios.isEmpty) {
      final ratio = Offset(
        horizontalPadding / parentWidth,
        (parentHeight - windowHeight - verticalPadding) / parentHeight,
      );

      windowPositionRatios.add(ratio);
      return ratio;
    }

    final lastWindowRatio = windowPositionRatios.last;

    // Convert the last window's position ratio to absolute coordinates.
    final lastWindowPosition = Offset(lastWindowRatio.dx * parentWidth, lastWindowRatio.dy * parentHeight);

    // Calculate the new x-position of the window.
    double x = lastWindowPosition.dx + windowWidth + horizontalPadding;

    // Handle horizontal overflow by wrapping to the next line.
    if (x + windowWidth + horizontalBoundaryPadding > parentWidth) {
      x = horizontalPadding;
      double y = lastWindowPosition.dy - windowHeight - verticalPadding;

      // Handle vertical overflow by moving the window to the bottom if needed.
      if (y < 0) y = parentHeight - windowHeight - verticalPadding;

      // Convert the new position to a ratio and add it to the list.
      final newRatio = Offset(x / parentWidth, y / parentHeight);

      windowPositionRatios.add(newRatio);
      return newRatio;
    }

    // Convert the new position to a ratio and add it to the list.
    final newRatio = Offset(x / parentWidth, (lastWindowPosition.dy) / parentHeight);

    windowPositionRatios.add(newRatio);
    return newRatio;
  }

  /// Adds a new window position ratio to the list if it doesn't already exist.
  void addWindowPosition(Offset position) {
    if (!windowPositionRatios.contains(position)) {
      windowPositionRatios.add(position);
    }
  }

  /// Removes a specific window position ratio from the list.
  void removeWindowPosition(Offset position) {
    windowPositionRatios.remove(position);
  }
}
