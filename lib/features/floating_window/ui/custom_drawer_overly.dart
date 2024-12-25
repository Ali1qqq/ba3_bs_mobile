import 'package:flutter/material.dart';

import '../managers/overlay_entry_with_priority_manager.dart';

class CustomDrawerOverly<T> extends StatefulWidget {
  final VoidCallback back;
  final OverlayEntryWithPriorityManager overlayEntryWithPriorityInstance;
  final BorderRadius? borderRadius;
  final EdgeInsets? contentPadding;
  final Alignment? dropdownAlignment;
  final ValueChanged<T>? onChanged;
  final double? height;
  final BoxDecoration? decoration;
  final int? priority;
  final VoidCallback? onCloseCallback;
  final TextStyle? textStyle;
  final Widget child;

  const CustomDrawerOverly({
    super.key,
    required this.overlayEntryWithPriorityInstance,
    this.onChanged,
    this.textStyle = const TextStyle(color: Colors.black),
    this.decoration,
    this.priority,
    required this.back,
    this.onCloseCallback,
    this.borderRadius,
    this.contentPadding,
    this.dropdownAlignment,
    required this.child,
    this.height,
  });

  @override
  State<CustomDrawerOverly<T>> createState() => _CustomDrawerOverlyState<T>();
}

class _CustomDrawerOverlyState<T> extends State<CustomDrawerOverly<T>> {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? overlayEntry;

  void _toggleDrawer() {
    if (overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final OverlayState overlay = Overlay.of(context);

    overlayEntry = _createOverlayEntry();

    // Display the overlay using the OverlayEntryWithPriorityManager with priority management
    widget.overlayEntryWithPriorityInstance.displayOverlay(
      overlay: overlay,
      overlayEntry: overlayEntry,
      contentPadding: widget.contentPadding,
      borderRadius: widget.borderRadius,
      overlayAlignment: widget.dropdownAlignment,
      priority: widget.priority,
      onCloseCallback: () {
        widget.onCloseCallback?.call();
        overlayEntry = null;
      },
    );
  }

  void _removeOverlay() {
    if (overlayEntry != null && overlayEntry!.mounted) {
      widget.back();
    }
  }

  Widget _buildDrawerContent() {
    return widget.child;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8.0),
              child: _buildDrawerContent(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDrawer,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          height: widget.height ?? 48.0,
          decoration: widget.decoration ?? const BoxDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  // child: Text(
                    // widget.itemLabelBuilder(widget.value),
                    // style: widget.textStyle,
                  // ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.black54, // Drawer arrow color
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
