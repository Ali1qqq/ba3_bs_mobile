import 'dart:async';

import 'package:ba3_bs_mobile/core/dialogs/custom_alert_dialog/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import 'models/custom_alert_type.dart';

class HelperAlert {
  static void showSuccess({
    required BuildContext context,
    required String text,
    String? title,
  }) {
    CustomAlertDialog.show(
      context: context,
      type: CustomAlertType.success,
      title: title ?? AppStrings.success.tr,
      text: text,
    );
  }

  static void showError({
    required BuildContext context,
    required String text,
    String? title,
  }) {
    CustomAlertDialog.show(
      context: context,
      type: CustomAlertType.error,
      title: title ?? AppStrings.error.tr,
      text: text,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String text,
    String? title,
  }) {
    CustomAlertDialog.show(
      context: context,
      type: CustomAlertType.warning,
      title: title ?? AppStrings.warning.tr,
      text: text,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String text,
    String? title,
  }) {
    CustomAlertDialog.show(
      context: context,
      type: CustomAlertType.info,
      title: title ?? AppStrings.info.tr,
      text: text,
    );
  }

  static void showLoading({
    required BuildContext context,
    String? title,
    required String text,
  }) {
    CustomAlertDialog.show(
      context: context,
      type: CustomAlertType.loading,
      title: title ?? AppStrings.loading.tr,
      text: text,
    );
  }

  static Future<bool> showConfirm({
    required BuildContext context,
    required String text,
    String? title,
    String? confirmText,
    String? cancelText,
    Color confirmColor = Colors.green,
    VoidCallback? onConfirm,
  }) async {
    final Completer<void> completer = Completer<void>();
    bool result = false;
    CustomAlertDialog.show(
      context: context,
      type: CustomAlertType.confirm,
      title: title ?? AppStrings.confirm.tr,
      text: text,
      confirmBtnText: confirmText ?? AppStrings.yes.tr,
      cancelBtnText: cancelText ?? AppStrings.no.tr,
      confirmBtnColor: confirmColor,
      onConfirmBtnTap: () {
        onConfirm?.call();
        result = true;
        completer.complete();
      },
      onCancelBtnTap: () {
        result = false;
        completer.complete();
      },
      barrierDismissible: false,
    );
    await completer.future;

    return result;
  }

  static void showCustomPhoneInput({
    required BuildContext context,
    required String title,
    required String text,
    required Function(String) onValidPhone,
  }) {
    String message = '';

    CustomAlertDialog.show(
      context: context,
      type: CustomAlertType.custom,
      barrierDismissible: true,
      title: title,
      text: text,
      confirmBtnText: AppStrings.save.tr,
      widget: TextFormField(
        decoration: InputDecoration(
          alignLabelWithHint: true,
          hintText: AppStrings.enterPhone.tr,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
        keyboardType: TextInputType.phone,
        onChanged: (value) => message = value,
      ),
      onConfirmBtnTap: () async {
        if (message.length < 5) {
          await CustomAlertDialog.show(
            context: context,
            type: CustomAlertType.error,
            text: AppStrings.invalidPhone.tr,
          );
          return;
        }
        // Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 300));
        if (!context.mounted) return;
        await CustomAlertDialog.show(
          context: context,
          type: CustomAlertType.success,
          text: "${AppStrings.savedNumber.tr} '$message'",
        );
        onValidPhone(message);
      },
    );
  }
}