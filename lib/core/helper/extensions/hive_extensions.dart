import 'package:hive_flutter/hive_flutter.dart';

import '../../services/local_database/implementations/services/hive_adapters_registrations.dart';

extension HiveInitialization on HiveInterface {
  Future<void> initializeApp() async {
    // Initialize Hive with Flutter support
    await initFlutter();

    HiveAdaptersRegistrations.registerAllAdapters();
  }
}

extension HiveAdapterregistezation<T> on TypeAdapter<T> {
  void registerAdapter() {
    // Register your adapters here
    Hive.registerAdapter(this);
  }
}
