import 'package:ba3_bs_mobile/core/helper/extensions/hive_extensions.dart';

import '../../../../../features/materials/data/models/materials/material_model.dart';

class HiveAdaptersRegistrations {
  static void registerAllAdapters() {
    MaterialModelAdapter().registerAdapter();
    MatExtraBarcodeModelAdapter().registerAdapter();
  }
}
