import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../core/bindings/bindings.dart';
import '../core/constants/app_strings.dart';
import '../core/helper/extensions/getx_controller_extensions.dart';
import '../core/router/app_router.dart';
import '../core/services/translation/app_translations.dart';
import '../core/services/translation/translation_controller.dart';
import '../core/styling/app_themes.dart';
import '../core/widgets/app_scroll_behavior.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TranslationController translationController = read<TranslationController>();

    return ScreenUtilInit(
      designSize: const Size(390, 852),
      splitScreenMode: true,
      fontSizeResolver: FontSizeResolvers.height,
      child: GetMaterialApp(
        initialBinding: AppBindings(),
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        locale: Locale(translationController.localLangCode),
        translations: AppTranslations(),
        fallbackLocale: Locale('en', 'US'),
        title: AppStrings.appTitle.tr,
        theme: AppThemes.defaultTheme,
        getPages: appRouter,
      ),
    );
  }
}
