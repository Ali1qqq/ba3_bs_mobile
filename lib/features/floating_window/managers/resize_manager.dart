import 'dart:ui';

class ResizeManager {
  final double edgeSize;

  ResizeManager({required this.edgeSize});

  bool isOnEdge(Offset position, double width, double height) =>
      _isOnCorner(position, width, height) ||
      isOnRightEdge(position, width) ||
      isOnLeftEdge(position) ||
      isOnTopEdge(position) ||
      isOnBottomEdge(position, height);

  bool isOnRightEdge(Offset position, double width) => position.dx >= width - edgeSize;

  bool isOnLeftEdge(Offset position) => position.dx <= edgeSize;

  bool isOnTopEdge(Offset position) => position.dy <= edgeSize;

  bool isOnBottomEdge(Offset position, double height) => position.dy >= height - edgeSize;

  bool _isOnCorner(Offset position, double width, double height) =>
      (isOnLeftEdge(position) || isOnRightEdge(position, width)) &&
      (isOnTopEdge(position) || isOnBottomEdge(position, height));

  bool isOnTopLeftCorner(Offset position) => isOnLeftEdge(position) && isOnTopEdge(position);

  bool isOnTopRightCorner(Offset position, double width) => isOnRightEdge(position, width) && isOnTopEdge(position);

  bool isOnBottomLeftCorner(Offset position, double height) =>
      isOnLeftEdge(position) && isOnBottomEdge(position, height);

  bool isOnBottomRightCorner(Offset position, double width, double height) =>
      isOnRightEdge(position, width) && isOnBottomEdge(position, height);
}
