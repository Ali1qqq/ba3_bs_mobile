import 'dart:developer';

import 'package:ba3_bs_mobile/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';
import '../interfaces/i_store_selection_handler.dart';

class StoreDropdown extends StatelessWidget {
  const StoreDropdown({super.key, required this.storeSelectionHandler, this.width});

  final IStoreSelectionHandler storeSelectionHandler;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('المستودع')),
          Expanded(
            child: Container(
              width: 1.sw - 100,
              height: AppConstants.constHeightTextField,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Obx(() {
                return OverlayService.showDropdown<StoreAccount>(
                  value: storeSelectionHandler.selectedStore.value,
                  items: StoreAccount.values,
                  onChanged: storeSelectionHandler.onSelectedStoreChanged,
                  textStyle: const TextStyle(fontSize: 14),
                  itemLabelBuilder: (store) => store.value,
                  height: AppConstants.constHeightTextField,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onCloseCallback: () {
                    log('StoreAccount Dropdown Overly Closed.');
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
