import 'package:flutter/material.dart';

import '../managers/overlay_entry_with_priority_manager.dart';
import '../ui/custom_dropdown_overly.dart';
import '../ui/custom_popup_menu_overly.dart';

class OverlayService {
  static final _entryWithPriorityInstance = OverlayEntryWithPriorityManager.instance;

  static void back() {
    _entryWithPriorityInstance.dispose();
  }

  static void showDialog({
    required BuildContext context,
    required Widget content,
    bool? showDivider,
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
    Alignment? dialogAlignment,
    String? title,
    double? width,
    double? height,
    int? priority,
    VoidCallback? onCloseCallback,
  }) {
    final OverlayState overlay = Overlay.of(context);

    _entryWithPriorityInstance.displayOverlay(
      overlay: overlay,
      showDivider: showDivider,
      borderRadius: borderRadius,
      contentPadding: contentPadding,
      overlayAlignment: dialogAlignment,
      title: title,
      content: content,
      width: width,
      height: height,
      priority: priority,
      onCloseCallback: onCloseCallback,
    );
  }

  static Widget showDropdown<T>({
    required T value,
    required List<T> items,
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
    Alignment? dropdownAlignment,
    required ValueChanged<T>? onChanged,
    required String Function(T item) itemLabelBuilder,
    double? height,
    BoxDecoration? decoration,
    int? priority,
    VoidCallback? onCloseCallback,
    TextStyle? textStyle,
  }) {
    return CustomDropdownOverly<T>(
      value: value,
      items: items,
      borderRadius: borderRadius,
      contentPadding: contentPadding,
      dropdownAlignment: dropdownAlignment,
      itemLabelBuilder: itemLabelBuilder,
      onChanged: onChanged,
      textStyle: textStyle,
      height: height,
      decoration: decoration,
      priority: priority,
      onCloseCallback: onCloseCallback,
      back: back,
      overlayEntryWithPriorityInstance: _entryWithPriorityInstance,
    );
  }

  static void showPopupMenu<T>({
    required BuildContext context,
    required Offset tapPosition,
    required List<T> items,
    required String Function(T item) itemLabelBuilder,
    required ValueChanged<T> onSelected,
    int? priority,
    VoidCallback? onCloseCallback,
    double elevation = 8.0,
    Color backgroundColor = Colors.white,
  }) {
    customPopupMenuOverlay<T>(
      context: context,
      tapPosition: tapPosition,
      items: items,
      back: back,
      priority: priority,
      onSelected: onSelected,
      onCloseCallback: onCloseCallback,
      itemLabelBuilder: itemLabelBuilder,
      overlayEntryWithPriorityInstance: _entryWithPriorityInstance,
    );
  }
}
