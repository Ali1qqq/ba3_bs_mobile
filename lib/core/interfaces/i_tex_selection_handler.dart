import 'package:get/get.dart';

import '../helper/enums/enums.dart';

abstract class ITexSelectionHandler {
  Rx<VatEnums> get selectedTax;

  void onSelectedTaxChanged(VatEnums? newTax);
}
