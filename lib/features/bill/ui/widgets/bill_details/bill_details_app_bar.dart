import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../floating_window/services/overlay_service.dart';
import '../../../controllers/bill/bill_details_controller.dart';

class BillDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BillDetailsAppBar({
    super.key,
    required this.billDetailsController,
    required this.billSearchController,
    required this.billTypeModel,
  });

  final BillDetailsController billDetailsController;
  final BillSearchController billSearchController;
  final BillTypeModel billTypeModel;

  // kToolbarHeight: default AppBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('${billTypeModel.fullName}'),
      actions: [
        Text('نوع الفاتورة: ', textDirection: TextDirection.rtl),
        SizedBox(
          width: 200,
          child: Obx(() {
            return OverlayService.showDropdown<InvPayType>(
              value: billDetailsController.selectedPayType.value,
              items: InvPayType.values,
              itemLabelBuilder: (type) => type.label,
              onChanged: (selectedType) {
                billDetailsController.onPayTypeChanged(selectedType);
              },
              textStyle: const TextStyle(fontSize: 14),
              height: AppConstants.constHeightTextField,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(5),
              ),
              onCloseCallback: () {
                log('InvPayType Dropdown Overly Closed.');
              },
            );
          }),
        ),
        IconButton(
          onPressed: () {
            billSearchController.previous();
          },
          icon: const Icon(Icons.keyboard_double_arrow_right),
        ),
        SizedBox(
          width: 200,
          child: CustomTextFieldWithoutIcon(
            isNumeric: true,
            textEditingController: billDetailsController.billNumberController,
            onSubmitted: (billNumber) {
              billSearchController.goToBillByNumber(billNumber.toInt);
            },
          ),
        ),
        IconButton(
          onPressed: () {
            billSearchController.next();
          },
          icon: const Icon(Icons.keyboard_double_arrow_left),
        ),
        const HorizontalSpace(20),
      ],
    );
  }
}

class BillDetailsCustomAppBar extends StatelessWidget {
  const BillDetailsCustomAppBar({
    super.key,
    required this.billDetailsController,
    required this.billSearchController,
    required this.billTypeModel,
  });

  final BillDetailsController billDetailsController;
  final BillSearchController billSearchController;
  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1.sw,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${billTypeModel.fullName}',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                      overflow: TextOverflow.ellipsis, // Avoid overflow
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        billDetailsController.showBarCodeScanner(context);
                      },
                      icon: Icon(Icons.qr_code_scanner_outlined, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            // const HorizontalSpace(8),
            Spacer(flex: 2),
            const Text('نوع الفاتورة: ', textDirection: TextDirection.rtl),
            const HorizontalSpace(8),
            SizedBox(
              width: 200,
              child: Obx(() {
                return OverlayService.showDropdown<InvPayType>(
                  value: billDetailsController.selectedPayType.value,
                  items: InvPayType.values,
                  itemLabelBuilder: (type) => type.label,
                  onChanged: (selectedType) {
                    billDetailsController.onPayTypeChanged(selectedType);
                  },
                  textStyle: const TextStyle(fontSize: 14),
                  height: AppConstants.constHeightTextField,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onCloseCallback: () {
                    log('InvPayType Dropdown Overlay Closed.');
                  },
                );
              }),
            ),
            IconButton(
              onPressed: () {
                billSearchController.previous();
              },
              icon: const Icon(Icons.keyboard_double_arrow_right),
            ),
            Expanded(
              child: CustomTextFieldWithoutIcon(
                isNumeric: true,
                textEditingController: billDetailsController.billNumberController,
                onSubmitted: (billNumber) {
                  billSearchController.goToBillByNumber(billNumber.toInt);
                },
              ),
            ),
            IconButton(
              onPressed: () {
                billSearchController.next();
              },
              icon: const Icon(Icons.keyboard_double_arrow_left),
            ),
            const HorizontalSpace(20),
          ],
        ),
      ),
    );
  }
}
