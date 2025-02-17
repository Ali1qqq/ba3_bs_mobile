import 'package:ba3_bs_mobile/core/services/translation/ur_translations.dart';
import 'package:ba3_bs_mobile/core/services/translation/zh_translations.dart';
import 'package:get/get.dart';

import 'ar_translations.dart';
import 'de_translations.dart';
import 'en_translations.dart';
import 'fr_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar_AR': arAR,
        'en_US': enUS,
        'ur_PK': urPK,
        'fr_FR': frFR,
        'de_DE': deDE,
        'zh_CN': zhCN,
      };
}