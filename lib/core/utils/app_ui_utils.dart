// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/dialogs/custom_alert_dialog/helper_alert.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../features/floating_window/services/overlay_service.dart';
import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';
import '../widgets/app_button.dart';
import '../widgets/app_spacer.dart';

class AppUIUtils {
  static void showToast(String text, {bool isSuccess = false, bool isInfo = false, bool long = false}) {
    Color color = Colors.red;
    if (isInfo) {
      color = Colors.orangeAccent;
    } else if (isSuccess) {
      color = Colors.green;
    }
    Fluttertoast.showToast(msg: text, backgroundColor: color, fontSize: 16.sp, toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT);
  }

  static String convertArabicNumbers(String input) {
    // Check if the input contains any non-Arabic characters
    final nonArabicRegex = RegExp(r'[^٠-٩]'); // Matches any character that is not an Arabic numeral

    // If the input contains any non-Arabic characters, return it unchanged
    if (nonArabicRegex.hasMatch(input)) {
      return input;
    }

    // Mapping of Arabic numerals to Western numerals
    const arabicToWestern = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    // Process the input and replace only Arabic numerals
    return input.split('').map((char) {
      return arabicToWestern[char] ?? char; // Replace Arabic numerals, keep others unchanged
    }).join('');
  }

  static String getDateFromString(String input) {
    // Convert Arabic numbers in the input to Western numbers
    input = convertArabicNumbers(input);

    DateTime now = DateTime.now();
    List<String> parts = input.split('-');

    try {
      if (parts.length == 3) {
        // Format: day-month-year (e.g., 15-5-2023)
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day).dayMonthYear;
      } else if (parts.length == 2) {
        // Format: day-month (e.g., 15-5)
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = now.year;
        return DateTime(year, month, day).dayMonthYear;
      } else if (parts.length == 1) {
        // Format: day only (e.g., 15)
        int day = int.parse(parts[0]);
        int month = now.month;
        int year = now.year;
        return DateTime(year, month, day).dayMonthYear;
      } else {
        // Invalid format, return today's date
        return DateTime.now().dayMonthYear;
      }
    } catch (e) {
      // Handle parsing errors and return today's date
      return DateTime.now().dayMonthYear;
    }
  }

  static List<String> getDatesBetween(DateTime startDate, DateTime endDate) {
    List<String> dates = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate.dayMonthYear);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  static void showExportSuccessDialog(String filePath, String successMessage, String title) {
    AppUIUtils.onSuccess(
      'تم تصدير الفواتير بنجاح!',
    );
    Get.defaultDialog(
      title: 'تم تصدير الملف إلى:',
      radius: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      content: Column(
        children: [
          Text(filePath),
          const VerticalSpace(16),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('نسخ المسار'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              AppUIUtils.onSuccess('تم نسخ المسار إلى الحافظة');
            },
          ),
        ],
      ),
    );
  }

  static String getPageNameFromEnum(String type) {
    switch (type) {
      case AppConstants.roleViewInvoice:
        return "الفواتير";
      case AppConstants.roleViewBond:
        return "السندات";
      case AppConstants.roleViewAccount:
        return "الحسابات";
      case AppConstants.roleViewMaterial:
        return "المواد";
      case AppConstants.roleViewStore:
        return "المستودعات";
      case AppConstants.roleViewPattern:
        return "انماط البيع";
      case AppConstants.roleViewCheques:
        return "الشيكات";
      case AppConstants.roleViewSeller:
        return "البائعون";
      case AppConstants.roleViewReport:
        return "تقارير المبيعات";
      case AppConstants.roleViewImport:
        return "استيراد المعلومات";
      case AppConstants.roleViewTarget:
        return "التارغت";
      case AppConstants.roleViewTask:
        return "التاسكات";
      case AppConstants.roleViewInventory:
        return "الجرد";
      case AppConstants.roleViewUserManagement:
        return "إدارة المستخدمين";
      case AppConstants.roleViewDue:
        return "الاستحقاق";
      case AppConstants.roleViewStatistics:
        return "التقارير";
      case AppConstants.roleViewTimer:
        return "الدوام";
      case AppConstants.roleViewDataBase:
        return "ادارة قواعد البيانات";
      case AppConstants.roleViewCard:
        return "ادارة البطاقات";
      case AppConstants.roleViewHome:
        return "الصفحة الرئيسية";
    }
    return "error";
  }

  static String getRoleNameFromEnum(String type) {
    switch (type) {
      case AppConstants.roleUserRead:
        return "القراءة";
      case AppConstants.roleUserWrite:
        return "الكتابة";
      case AppConstants.roleUserUpdate:
        return "التعديل";
      case AppConstants.roleUserDelete:
        return "الحذف";
      case AppConstants.roleUserAdmin:
        return "الإدارة";
    }
    return "error";
  }

  static String getNameOfRoleFromEnum(String type) {
    switch (type) {
      case AppConstants.roleUserRead:
        return "قراءة البيانات";
      case AppConstants.roleUserWrite:
        return "كتابة البيانات";
      case AppConstants.roleUserUpdate:
        return "تعديل البيانات";
      case AppConstants.roleUserDelete:
        return "حذف البيانات";
      case AppConstants.roleUserAdmin:
        return "إدارة البيانات";
    }
    return type;
  }

  static String formatDecimalNumberWithCommas(double number) {
    if (number == 0) return '0.00';

    // ضبط الرقم العشري إلى رقمين بعد الفاصلة
    String formattedNumber = number.toStringAsFixed(2);

    // تحويل الرقم إلى سلسلة نصية وتجزئته إلى جزء صحيح وجزء عشري
    List<String> parts = formattedNumber.split('.');
    String integerPart = parts[0]; // الجزء الصحيح
    String decimalPart = parts[1]; // الجزء العشري المحدد إلى رقمين

    // تنسيق الجزء الصحيح باستخدام RegExp لإضافة الفاصلة كل ثلاث خانات
    String formattedIntegerPart = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    final formattedValue = '$formattedIntegerPart.$decimalPart';
    return formattedValue == '-0.00' ? '0.00' : formattedValue;
  }

  static Widget showLoadingIndicator({
    double width = 20,
    double height = 20,
    Color? color = Colors.white,
  }) =>
      Center(
        child: SizedBox(width: width, height: height, child: CircularProgressIndicator(color: color)),
      );

  static showErrorSnackBar({String? title, required String message, NotificationStatus status = NotificationStatus.error}) {
    // Close any existing SnackBar
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    // Show the new SnackBar
    Get.snackbar(
      title ?? _getTitle(status),
      message,
      backgroundColor: _getBackgroundColor(status),
      icon: Icon(
        _getIcon(status),
        color: Colors.white,
      ),
      barBlur: 10,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }

  static showSuccessSnackBar({String? title, required String message, NotificationStatus status = NotificationStatus.success}) {
    // Close any existing SnackBar
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    // Show the new SnackBar
    Get.snackbar(
      title ?? _getTitle(status),
      message,
      backgroundColor: _getBackgroundColor(status),
      icon: Icon(
        _getIcon(status),
        color: Colors.white,
      ),
      barBlur: 10,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }

  static void showInfoSnackBar({
    String? title,
    required String message,
    NotificationStatus status = NotificationStatus.info,
  }) {
    Get.closeAllSnackbars();

    // Show the new SnackBar
    Get.snackbar(
      title ?? _getTitle(status),
      message,
      backgroundColor: _getBackgroundColor(status),
      icon: Icon(
        _getIcon(status),
        color: Colors.white,
      ),
      barBlur: 10,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }

  static String _getTitle(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.success:
        return 'نجاح';
      case NotificationStatus.error:
        return 'خطأ';
      case NotificationStatus.info:
        return 'تنبية';
    }
  }

  /// 🔹 Get Dynamic Background Color Based on Status
  static Color _getBackgroundColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.success:
        return Colors.green.withOpacity(0.8);
      case NotificationStatus.error:
        return Colors.red.withOpacity(0.8);
      case NotificationStatus.info:
        return Colors.blue.withOpacity(0.8);
    }
  }

  /// 🔹 Get Dynamic Icon Based on Status
  static IconData _getIcon(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.success:
        return Icons.check_circle;
      case NotificationStatus.error:
        return Icons.error;
      case NotificationStatus.info:
        return Icons.info;
    }
  }

  static onFailure(String message) => HelperAlert.showError(text: message);

  static onSuccess(String message) => HelperAlert.showSuccess(text: message);

  static onInfo(String message, String title) => HelperAlert.showInfo(text: message, title: title);

  /// The `title` argument is used to title of alert dialog.
  /// The `content` argument is used to content of alert dialog.
  /// The `textOK` argument is used to text for 'OK' Button of alert dialog.
  /// The `textCancel` argument is used to text for 'Cancel' Button of alert dialog.
  /// The `canPop` argument is `canPop` of PopScope.
  /// The `onPopInvokedWithResult` argument is `onPopInvokedWithResult` of PopScope.
  ///
  /// Returns a [Future<bool>].
  static Future<bool> confirm(
    BuildContext context, {
    String? title,
    Widget? content,
    Widget? textOK,
    Widget? textCancel,
    bool canPop = false,
    void Function(bool, dynamic)? onPopInvokedWithResult,
  }) async {
    final bool? isConfirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => PopScope(
        canPop: true,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.red)),
          alignment: Alignment.center,
          backgroundColor: AppColors.backGroundColor,
          title: title == null
              ? null
              : Center(
                  child: Text(
                    title,
                    style: AppTextStyles.headLineStyle2,
                  ),
                ),
          content: title != null
              ? null
              : Text(
                  AppStrings.areYouSureContinue.tr,
                  style: AppTextStyles.headLineStyle2,
                  textAlign: TextAlign.center,
                ),
          actions: <Widget>[
            AppButton(
              title: AppConstants.no,
              onPressed: () => Navigator.pop(context, false),
              iconData: Icons.clear,
              width: 80,
            ),
            const HorizontalSpace(20),
            AppButton(
              title: AppConstants.yes,
              onPressed: () => Navigator.pop(context, true),
              color: Colors.red,
              iconData: Icons.check,
              width: 80,
            ),
          ],
        ),
      ),
    );
    return isConfirm ?? false;
  }

  static Future<bool> confirmOverlay(
    BuildContext context, {
    String? title,
    Widget? content,
    Widget? textOK,
    Widget? textCancel,
    bool canPop = false,
    void Function(bool, dynamic)? onPopInvokedWithResult,
  }) async {
    final completer = Completer<bool>();

    await OverlayService.showDialog(
      context: context,
      height: 200,
      width: 350,
      title: title ?? AppStrings.confirm.tr,
      content: Builder(
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (content != null)
              content
            else
              Text(
                AppStrings.areYouSureContinue.tr,
                style: AppTextStyles.headLineStyle2,
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  title: AppConstants.no,
                  onPressed: () {
                    if (!completer.isCompleted) {
                      Future.microtask(() {
                        OverlayService.back();
                      });
                      completer.complete(false);
                    }
                  },
                  iconData: Icons.clear,
                  width: 80,
                ),
                const HorizontalSpace(20),
                AppButton(
                  title: AppConstants.yes,
                  onPressed: () {
                    if (!completer.isCompleted) {
                      Future.microtask(() {
                        OverlayService.back();
                      });
                      completer.complete(true);
                    }
                  },
                  color: Colors.red,
                  iconData: Icons.check,
                  width: 80,
                ),
              ],
            ),
            const VerticalSpace(15),
          ],
        ),
      ),
      borderRadius: BorderRadius.circular(15),
      color: AppColors.backGroundColor,
      dialogAlignment: Alignment.center,
      onCloseCallback: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        onPopInvokedWithResult?.call(false, null);
      },
    );

    return completer.future;
  }

  static void showFullScreenFileImage(BuildContext context, String imagePath) {
    OverlayService.showDialog(
      context: context,
      width: 1.sw,
      height: 1.sh,
      content: InteractiveViewer(
        child: Image.file(File(imagePath), fit: BoxFit.contain),
      ),
    );
  }

  static void showFullScreenNetworkImage(BuildContext context, String imagePath) {
    OverlayService.showDialog(
      context: context,
      width: 1.sw,
      height: 1.sh,
      content: InteractiveViewer(
        child: Image.network(imagePath, fit: BoxFit.contain),
      ),
    );
  }
}