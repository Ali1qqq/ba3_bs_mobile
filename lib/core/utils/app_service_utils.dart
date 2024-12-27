import 'package:ba3_bs_mobile/core/helper/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/accounts/controllers/accounts_controller.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../helper/extensions/getx_controller_extensions.dart';

class AppServiceUtils {
  static String formatSecretEmail(String email) {
    final firstPart = email.split("@").first;
    final lastPart = email.split("@").last;
    var secretFormatted = "";
    for (int i = 0; i < firstPart.length; i++) {
      secretFormatted += (i == 0 || i == firstPart.length - 1) ? firstPart[i] : "*";
    }
    return "$secretFormatted@$lastPart";
  }

  static DateTime? convertStringToDateTime(String? dateString) {
    if (dateString == null) return null;
    final DateFormat dateFormat;
    if (RegExp(r"\d+m").hasMatch(dateString)) {
      final minutes = int.parse(dateString.replaceAll("m", ""));
      return DateTime.now().add(Duration(minutes: minutes));
    } else {
      dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
    }
    return dateFormat.parse(dateString);
  }

  static String? convertDateTimeToString(DateTime? date) {
    if (date == null) return null;
    DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
    return dateFormat.format(date);
  }

  static String capitalizeString({required String text}) {
    String newText = "";
    for (int i = 0; i < text.length; i++) {
      if (i == 0 || (i - 1 >= 0 && (text[i - 1] == " "))) {
        newText += text[i].toUpperCase();
      } else {
        newText += text[i];
      }
    }
    return newText;
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String convertFeetToFeetInches(double feet) {
    int feetPart = feet.floor();
    double inchesPart = (feet - feetPart) * 12.0;
    int inches = inchesPart.round();
    return '$feetPart\'$inches';
  }

  static String replaceArabicNumbersWithEnglish(String input) {
    return input.replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }

  static String extractNumbersAndCalculate(String input) {
    // استبدال الفاصلة العربية بالنقطة

    input = replaceArabicNumbersWithEnglish(input);
    String cleanedInput = input.replaceAll('٫', '.');

    // تحقق مما إذا كانت السلسلة تحتوي على معاملات حسابية
    bool hasOperators = cleanedInput.contains(RegExp(r'[+\-*/]'));

    // معالجة الفواصل الزائدة بحيث تبقى فقط الفاصلة الأولى
    cleanedInput = cleanedInput.replaceAllMapped(RegExp(r'(\d+)\.(\d+)\.(\d+)'), (match) {
      return '${match.group(1)}.${match.group(2)}';
    });
    if (hasOperators) {
      // إذا كان هناك معاملات، قم باستخراج الأرقام والعمليات وإجراء الحسابات
      RegExp regex = RegExp(r'[0-9.]+|[+\-*/]');
      Iterable<Match> matches = regex.allMatches(cleanedInput);
      List<String> elements = matches.map((match) => match.group(0)!).toList();

      List<double> numbers = [];
      String? operation;

      for (var element in elements) {
        if (double.tryParse(element) != null) {
          double number = double.parse(element);
          if (operation == null) {
            numbers.add(number);
          } else {
            double lastNumber = numbers.removeLast();
            switch (operation) {
              case '+':
                numbers.add(lastNumber + number);
                break;
              case '-':
                numbers.add(lastNumber - number);
                break;
              case '*':
                numbers.add(lastNumber * number);
                break;
              case '/':
                numbers.add(lastNumber / number);
                break;
            }
            operation = null;
          }
        } else {
          operation = element;
        }
      }

      return numbers.isNotEmpty ? numbers.first.toString() : "0.0";
    } else {
      //! إذا لم يكن هناك معاملات، فقط استخرج الأرقام /
      RegExp regex = RegExp(r'[0-9.]+');
      Iterable<Match> matches = regex.allMatches(cleanedInput);
      List<double> numbers = matches.map((match) => double.parse(match.group(0)!)).toList();

      // إذا لم توجد أرقام، قم بإرجاع 0
      return numbers.isNotEmpty ? numbers.first.toString() : "0.0";
    }
  }

  static String getAccountType(int? type) {
    switch (type) {
      case 0:
        return 'حساب عادي';
      case 1:
        return 'حساب ختامي';
      case 2:
        return 'حساب تجميعي';
      default:
        return 'حساب عادي';
    }
  }

  static String getAccountAccDebitOrCredit(int? type) {
    switch (type) {
      case 0:
        return 'Debit';
      case 1:
        return 'Credit';
      default:
        return 'Debit';
    }
  }

  static double toFixedDouble(double? value, [int fractionDigits = 2]) => double.tryParse(value?.toStringAsFixed(fractionDigits) ?? '0') ?? 0.0;

  static double calcSub(int vatRatio, double total) {
    double sub = total / (1 + (vatRatio / 100));

    return sub;
  }

  static double calcVat(int? vatRatio, double? total) {
    if (vatRatio == null || vatRatio == 0 || total == null || total == 0) return 0;

    double sunTotal = calcSub(vatRatio, total);

    return total - sunTotal;
  }

  static int getItemQuantity(PlutoRow row, String cellKey) {
    final String cellValue = row.cells[cellKey]?.value.toString() ?? '';

    int invRecQuantity = AppServiceUtils.replaceArabicNumbersWithEnglish(cellValue).toInt ?? 1;

    return invRecQuantity;
  }

  static String zeroToEmpty(double? value) => value == null || value == 0 ? '' : value.toStringAsFixed(2);

  // Generates a unique tag for identifying controllers.
  static String generateUniqueTag(String controllerName) => '${controllerName}_${UniqueKey().toString()}';

  static AccountModel? getAccountModelFromLabel(accLabel) => read<AccountsController>()
      .accounts
      .where(
        (element) => element.accName == accLabel || element.id == accLabel,
      )
      .firstOrNull;

  static String generateUniqueId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  static String formatDateTime(DateTime dateTime) {
    // DateTime dateTime = DateTime.parse(isoString);
    // print(dateTime);
    String period = dateTime.hour >= 12 ? "PM" : "AM";

    int hour = dateTime.hour % 12;
    if (hour == 0) hour = 12;

    String formattedDateTime = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} \n"
        "${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period";
    return formattedDateTime;
  }

  static String getDayNameAndMonthName(String inputDate) {
    DateTime date = DateTime.parse(inputDate);
    String dayName = DateFormat.EEEE().format(date);
    String monthName = DateFormat.MMMM().format(date);
    String year = DateFormat.y().format(date);
    return "$dayName - $monthName -  $year";
  }
}
