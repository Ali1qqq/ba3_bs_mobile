// ignore_for_file: deprecated_member_use

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
  static Future<void> show({
    required CustomAlertType type,
    String? title,
    String? text,
    TextAlign? titleAlignment,
    TextAlign? textAlignment,
    Widget? widget,
    bool barrierDismissible = true,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
    String? confirmBtnText,
    String? cancelBtnText,
    Color confirmBtnColor = Colors.blue,
    Color cancelBtnColor = Colors.redAccent,
    bool showCancelBtn = false,
    bool showConfirmBtn = true,
    double borderRadius = 15.0,
    Duration? autoCloseDuration,
  }) async {
    if (autoCloseDuration != null) {
      Future.delayed(autoCloseDuration, () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      });
    }

    // Determine icon based on alert type
    IconData? iconData;
    Color iconColor = confirmBtnColor;

    switch (type) {
      case CustomAlertType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case CustomAlertType.error:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
      case CustomAlertType.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case CustomAlertType.info:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      case CustomAlertType.custom:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      case CustomAlertType.confirm:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      case CustomAlertType.loading:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
    }

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon section
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 48,
                ),
              ),

              // Title
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title,
                    textAlign: titleAlignment ?? TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

              // Content
              if (widget != null || text != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: widget ??
                      Text(
                        text!,
                        textAlign: textAlignment ?? TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showCancelBtn)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            onCancelBtnTap?.call();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: cancelBtnColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: cancelBtnColor.withOpacity(0.3),
                              ),
                            ),
                          ),
                          child: Text(
                            cancelBtnText ?? "Cancel",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showConfirmBtn)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: showCancelBtn ? 8 : 0,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.pop(context);
                            Navigator.of(Get.context!).pop();

                            onConfirmBtnTap?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmBtnColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            confirmBtnText ?? ("Done"),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}

// class CustomAlertDialog {
//   static final List<OverlayEntry> _overlays = [];

//   static Future<void> show({
//     BuildContext? context,
//     required CustomAlertType type,
//     String? title,
//     String? text,
//     TextAlign? titleAlignment,
//     TextAlign? textAlignment,
//     Widget? widget,
//     CustomAlertAnimType animType = CustomAlertAnimType.scale,
//     bool barrierDismissible = true,
//     VoidCallback? onConfirmBtnTap,
//     VoidCallback? onCancelBtnTap,
//     String? confirmBtnText,
//     String? cancelBtnText,
//     Color confirmBtnColor = Colors.blue,
//     Color cancelBtnColor = Colors.redAccent,
//     TextStyle? confirmBtnTextStyle,
//     TextStyle? cancelBtnTextStyle,
//     Color backgroundColor = Colors.white,
//     Color headerBackgroundColor = Colors.white,
//     Color titleColor = Colors.black,
//     Color textColor = Colors.black,
//     Color? barrierColor,
//     bool showCancelBtn = false,
//     bool showConfirmBtn = true,
//     double borderRadius = 15.0,
//     String? customAsset,
//     double? width,
//     Duration? autoCloseDuration,
//     bool disableBackBtn = false,
//   }) async {
//     Timer? timer;

//     final validContext = context ?? Get.overlayContext!;
//     final overlay = Overlay.of(validContext, rootOverlay: true);

//     if (autoCloseDuration != null) {
//       timer = Timer(autoCloseDuration, () {
//         hide();
//       });
//     }

//     final options = CustomAlertOptions(
//       timer: timer,
//       title: title,
//       text: text,
//       titleAlignment: titleAlignment,
//       textAlignment: textAlignment,
//       widget: widget,
//       type: type,
//       animType: animType,
//       barrierDismissible: barrierDismissible,
//       onConfirmBtnTap: () {
//         hide();
//         onConfirmBtnTap?.call();
//       },
//       onCancelBtnTap: () {
//         hide();
//         onCancelBtnTap?.call();
//       },
//       confirmBtnText: confirmBtnText ?? AppStrings.done,
//       cancelBtnText: cancelBtnText ?? AppStrings.cancel,
//       confirmBtnColor: confirmBtnColor,
//       cancelBtnColor: cancelBtnColor,
//       confirmBtnTextStyle: confirmBtnTextStyle,
//       cancelBtnTextStyle: cancelBtnTextStyle,
//       backgroundColor: backgroundColor,
//       headerBackgroundColor: headerBackgroundColor,
//       titleColor: titleColor,
//       textColor: textColor,
//       showCancelBtn: showCancelBtn,
//       showConfirmBtn: showConfirmBtn,
//       borderRadius: borderRadius,
//       customAsset: customAsset,
//       width: width,
//     );

//     Widget alert = AlertDialog(
//       contentPadding: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadius),
//       ),
//       content: CustomAlertContainer(options: options),
//     );

//     if (type != CustomAlertType.loading) {
//       alert = RawKeyboardListener(
//         focusNode: FocusNode(),
//         autofocus: true,
//         onKey: (event) {
//           if (event is RawKeyUpEvent && event.logicalKey == LogicalKeyboardKey.enter) {
//             hide();
//             onConfirmBtnTap?.call();
//           }
//         },
//         child: alert,
//       );
//     }

//     Widget dialog = Material(
//       color: barrierColor ?? Colors.black.withOpacity(0.5),
//       child: GestureDetector(
//         onTap: () {
//           if (barrierDismissible) hide();
//         },
//         child: Center(
//           child: CustomAlertAnimate.getByType(
//             animType,
//             child: alert,
//             animation: const AlwaysStoppedAnimation(1.0),
//           ),
//         ),
//       ),
//     );

//     final entry = OverlayEntry(builder: (_) => dialog);
//     overlay.insert(entry);
//     _overlays.add(entry);
//   }

//   /// يغلق آخر تنبيه مفتوح
//   static void hide() {
//     if (_overlays.isNotEmpty) {
//       final last = _overlays.removeLast();
//       last.remove();
//     }
//   }

//   /// يغلق جميع التنبيهات المفتوحة
//   static void hideAll() {
//     for (final entry in _overlays) {
//       entry.remove();
//     }
//     _overlays.clear();
//   }
// }
