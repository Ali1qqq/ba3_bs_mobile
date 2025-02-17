import 'dart:ui';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/locale_extensions.dart';
import 'package:get/get.dart';

import '../../constants/app_assets.dart';
import '../local_database/interfaces/i_local_database_service.dart';

class TranslationController extends GetxController {
  final ILocalDatabaseService<String> appLocalLangService;

  TranslationController(this.appLocalLangService);

  String get localLangCode => appLocalLangService.fetchById(AppConstants.appLocalLangBox) ?? AppConstants.defaultLangCode;

  Future<void> changeLang(String langCode) async {
    await appLocalLangService.insert(AppConstants.appLocalLangBox, langCode);
    Get.updateLocale(Locale(langCode));
  }

  String getLanguageName(String langCode) {
    switch (langCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ur':
        return 'اردو';
      case 'zh':
        return '中国';
      case 'fr':
        return 'France';
      case 'de':
        return 'Deutsch';
      default:
        return langCode;
    }
  }

  String getFlagAsset(String langCode) {
    switch (langCode) {
      case 'en':
        return AppAssets.enFlag;
      case 'ar':
        return AppAssets.arFlag;
      case 'ur':
        return AppAssets.urFlag;
      case 'zh':
        return AppAssets.zhFlag;
      case 'fr':
        return AppAssets.frFlag;
      case 'de':
        return AppAssets.deFlag;
      default:
        return AppAssets.enFlag;
    }
  }

  String? get currentLangCode => Get.locale?.languageCode;

  bool get currentLocaleIsRtl => Locale(currentLangCode!).isRtl;
}