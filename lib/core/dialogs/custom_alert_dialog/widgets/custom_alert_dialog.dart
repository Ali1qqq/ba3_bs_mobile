import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/custom_alert_anim_type.dart';
import '../models/custom_alert_options.dart';
import '../models/custom_alert_type.dart';
import '../utils/custom_alert_animate.dart';
import 'custom_alert_container.dart';

class CustomAlertDialog {
  static OverlayEntry? _currentOverlay;

  static Future<void> show({
    required BuildContext context,
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
    String confirmBtnText = 'Okay',
    String cancelBtnText = 'Cancel',
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
    final overlay = Overlay.of(context, rootOverlay: true);

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
      confirmBtnText: confirmBtnText,
      cancelBtnText: cancelBtnText,
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
      alert = KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            hide();
            onConfirmBtnTap?.call();
          }
        },
        child: alert,
      );
    }

    Widget dialog = Material(
      color: barrierColor ?? Colors.black.withAlpha(127),
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

    _currentOverlay = OverlayEntry(builder: (_) => dialog);
    overlay.insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}