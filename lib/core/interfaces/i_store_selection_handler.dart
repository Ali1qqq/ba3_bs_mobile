import 'package:get/get.dart';

import '../helper/enums/enums.dart';

abstract class IStoreSelectionHandler {
  Rx<StoreAccount> get selectedStore;

  void onSelectedStoreChanged(StoreAccount? newStore);
}
