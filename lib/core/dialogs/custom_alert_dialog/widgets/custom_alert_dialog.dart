import 'dart:async';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/custom_alert_anim_type.dart';
import '../models/custom_alert_options.dart';
import '../models/custom_alert_type.dart';
import '../utils/custom_alert_animate.dart';
import 'custom_alert_container.dart';

class CustomAlertDialog {
  static final List<OverlayEntry> _overlays = [];

  static Future<void> show({
    BuildContext? context,
    required CustomAlertType type,
    String? title,
    String? text,
    TextAlign? titleAlignment,
    TextAlign? textAlignment,
    Widget? widget,
    CustomAlertAnimType animType = CustomAlertAnimType.scale,
    bool barrierDismissible = true,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
    String? confirmBtnText,
    String? cancelBtnText,
    Color confirmBtnColor = Colors.blue,
    Color cancelBtnColor = Colors.redAccent,
    TextStyle? confirmBtnTextStyle,
    TextStyle? cancelBtnTextStyle,
    Color backgroundColor = Colors.white,
    Color headerBackgroundColor = Colors.white,
    Color titleColor = Colors.black,
    Color textColor = Colors.black,
    Color? barrierColor,
    bool showCancelBtn = false,
    bool showConfirmBtn = true,
    double borderRadius = 15.0,
    String? customAsset,
    double? width,
    Duration? autoCloseDuration,
    bool disableBackBtn = false,
  }) async {
    Timer? timer;

    final validContext = context ?? Get.overlayContext!;
    final overlay = Overlay.of(validContext, rootOverlay: true);

    if (autoCloseDuration != null) {
      timer = Timer(autoCloseDuration, () {
        hide();
      });
    }

    final options = CustomAlertOptions(
      timer: timer,
      title: title,
      text: text,
      titleAlignment: titleAlignment,
      textAlignment: textAlignment,
      widget: widget,
      type: type,
      animType: animType,
      barrierDismissible: barrierDismissible,
      onConfirmBtnTap: () {
        hide();
        onConfirmBtnTap?.call();
      },
      onCancelBtnTap: () {
        hide();
        onCancelBtnTap?.call();
      },
      confirmBtnText: confirmBtnText ?? AppStrings.done,
      cancelBtnText: cancelBtnText ?? AppStrings.cancel,
      confirmBtnColor: confirmBtnColor,
      cancelBtnColor: cancelBtnColor,
      confirmBtnTextStyle: confirmBtnTextStyle,
      cancelBtnTextStyle: cancelBtnTextStyle,
      backgroundColor: backgroundColor,
      headerBackgroundColor: headerBackgroundColor,
      titleColor: titleColor,
      textColor: textColor,
      showCancelBtn: showCancelBtn,
      showConfirmBtn: showConfirmBtn,
      borderRadius: borderRadius,
      customAsset: customAsset,
      width: width,
    );

    Widget alert = AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      content: CustomAlertContainer(options: options),
    );

    if (type != CustomAlertType.loading) {
      alert = RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyUpEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            hide();
            onConfirmBtnTap?.call();
          }
        },
        child: alert,
      );
    }

    Widget dialog = Material(
      color: barrierColor ?? Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: () {
          if (barrierDismissible) hide();
        },
        child: Center(
          child: CustomAlertAnimate.getByType(
            animType,
            child: alert,
            animation: const AlwaysStoppedAnimation(1.0),
          ),
        ),
      ),
    );

    final entry = OverlayEntry(builder: (_) => dialog);
    overlay.insert(entry);
    _overlays.add(entry);
  }

  /// يغلق آخر تنبيه مفتوح
  static void hide() {
    if (_overlays.isNotEmpty) {
      final last = _overlays.removeLast();
      last.remove();
    }
  }

  /// يغلق جميع التنبيهات المفتوحة
  static void hideAll() {
    for (final entry in _overlays) {
      entry.remove();
    }
    _overlays.clear();
  }
}