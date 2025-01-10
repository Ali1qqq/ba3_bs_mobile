import 'package:ba3_bs_mobile/core/helper/extensions/hive_extensions.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';

class HiveAdaptersRegistrations {
  static void registerAllAdapters() {
    MaterialModelAdapter().registerAdapter();
    MatExtraBarcodeModelAdapter().registerAdapter();
  }
}
