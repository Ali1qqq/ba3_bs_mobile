import 'dart:async';

import 'package:flutter/widgets.dart';

import 'custom_alert_anim_type.dart';
import 'custom_alert_type.dart';

/// Alert Options
class CustomAlertOptions {
  /// Title of the dialog
  String? title;

  /// Text of the dialog
  String? text;

  /// TitleAlignment of the dialog
  TextAlign? titleAlignment;

  /// TextAlignment of the dialog
  TextAlign? textAlignment;

  /// Custom Widget of the dialog
  Widget? widget;

  /// Alert type [success, error, warning, confirm, info, loading, custom]
  CustomAlertType type;

  /// Animation type  [scale, rotate, slideInDown, slideInUp, slideInLeft, slideInRight]
  CustomAlertAnimType? animType;

  /// Barrier dismissible
  bool? barrierDismissible = false;

  /// Triggered when confirm button is tapped
  VoidCallback? onConfirmBtnTap;

  /// Triggered when cancel button is tapped
  VoidCallback? onCancelBtnTap;

  /// Confirmation button text
  String? confirmBtnText;

  /// Cancel button text
  String? cancelBtnText;

  /// Color for confirm button
  Color? confirmBtnColor;

  /// Color for confirm button
  Color? cancelBtnColor;

  /// TextStyle for confirm button
  TextStyle? confirmBtnTextStyle;

  /// TextStyle for cancel button
  TextStyle? cancelBtnTextStyle;

  /// Backgroung Color for dialog
  Color? backgroundColor;

  /// Header Backgroung Color for dialog
  Color? headerBackgroundColor;

  /// Color of title
  Color? titleColor;

  /// Color of text
  Color? textColor;

  /// Determines if cancel button is shown or not
  bool? showCancelBtn;

  /// Determines if confirm button is shown or not
  bool? showConfirmBtn;

  /// Dialog Border Radius
  double? borderRadius;

  /// Asset path of your Image file
  String? customAsset;

  /// Width of the dialog
  double? width;

  /// timer for dismissing dialog (Ok button)
  Timer? timer;

  /// Alert Options
  CustomAlertOptions({
    /// Title of the dialog
    this.title,

    /// Text of the dialog
    this.text,

    /// TitleAlignment of the dialog
    this.titleAlignment,

    /// TextAlignment of the dialog
    this.textAlignment,

    /// Custom Widget of the dialog
    this.widget,

    /// Alert type [success, error, warning, confirm, info, loading, custom]
    required this.type,

    /// Animation type  [scale, rotate, slideInDown, slideInUp, slideInLeft, slideInRight]
    this.animType,

    /// Barrier Dissmisable
    this.barrierDismissible,

    /// Triggered when confirm button is tapped
    this.onConfirmBtnTap,

    /// Triggered when cancel button is tapped
    this.onCancelBtnTap,

    /// Confirmation button text
    this.confirmBtnText,

    /// Cancel button text
    this.cancelBtnText,

    /// Color for confirm button
    this.confirmBtnColor,

    /// Color for confirm button
    this.cancelBtnColor,

    /// TextStyle for confirm button
    this.confirmBtnTextStyle,

    /// TextStyle for cancel button
    this.cancelBtnTextStyle,

    /// Backgroung Color for dialog
    this.backgroundColor,

    /// Header Backgroung Color for dialog
    this.headerBackgroundColor,

    /// Color of title
    this.titleColor,

    /// Color of text
    this.textColor,

    /// Determines if cancel button is shown or not
    this.showCancelBtn,

    /// Determines if confirm button is shown or not
    this.showConfirmBtn,

    /// Dialog Border Radius
    this.borderRadius,

    /// Asset path of your Image file
    this.customAsset,

    /// Width of the dialog
    this.width,

    /// timer for dismissing dialog (Ok button)
    this.timer,
  });
}
