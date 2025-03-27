import 'dart:developer';

import 'package:flutter/material.dart';

import 'apps/app.dart';
import 'apps/blocked_app.dart';
import 'core/helper/init_app/app_initializer.dart';
import 'core/services/firebase/implementations/services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppServices();

  final isAppEnabled = RemoteConfigService.isAppEnabled;
  log('isAppEnabled: $isAppEnabled', name: 'RemoteConfigService');
  runApp(isAppEnabled ? const MyApp() : const BlockedApp());
}