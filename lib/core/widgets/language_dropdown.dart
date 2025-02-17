import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../services/translation/translation_controller.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final TranslationController translationController = Get.find<TranslationController>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.h),
      height: AppConstants.constHeightTextField * 2,
      width: 1.sw,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          value: translationController.currentLangCode,
          dropdownStyleData: DropdownStyleData(
            offset: Offset(0, -10),
            maxHeight: 200,
          ),
          hint: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 24,
          ),
          onChanged: (String? newLangCode) {
            if (newLangCode != null) {
              translationController.changeLang(newLangCode);
            }
          },
          items: AppConstants.locales.map((String langCode) {
            return DropdownMenuItem<String>(
              value: langCode,
              child: Row(
                children: [
                  Image.asset(
                    translationController.getFlagAsset(langCode),
                    width: 0.080.sw,
                    height: 0.020.sh,
                    fit: BoxFit.cover,
                  ),
                  HorizontalSpace(),
                  Text(
                    translationController.getLanguageName(langCode),
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}