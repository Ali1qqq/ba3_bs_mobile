import 'dart:io';

import 'package:ba3_bs_mobile/core/helper/extensions/hive_extensions.dart';
import 'package:easy_notifications/easy_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:window_manager/window_manager.dart';

import '../../../firebase_options.dart';
import '../../constants/app_constants.dart';
import '../../services/local_database/implementations/services/hive_database_service.dart';
import '../../services/translation/translation_controller.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyNotifications.init();

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
    await initializeWindowSettings();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initializeApp();

  await _initializeAppLocalLangService(boxName: AppConstants.appLocalLangBox);
}

Future<void> _initializeAppLocalLangService({required String boxName}) async {
  final Box<String> box = await Hive.openBox<String>(boxName);

  final HiveDatabaseService<String> hiveLocalLangService = HiveDatabaseService(box);

  Get.put(TranslationController(hiveLocalLangService));
}

Future<void> initializeWindowSettings() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 800),
    minimumSize: Size(1000, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}