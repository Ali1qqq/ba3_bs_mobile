import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
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
      leadingWidth: 100,
      title: Text('${billTypeModel.fullName}'),
      actions: [
        SizedBox(
          height: AppConstants.constHeightTextField,
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        "نوع الفاتورة" ": ",
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Expanded(
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
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        billSearchController.previous();
                      },
                      icon: const Icon(Icons.keyboard_double_arrow_right)),
                  SizedBox(
                      width: Get.width * 0.10,
                      child: CustomTextFieldWithoutIcon(
                        isNumeric: true,
                        textEditingController: billDetailsController.billNumberController,
                        onSubmitted: (billNumber) {
                          billSearchController.goToBillByNumber(billNumber.toInt);
                        },
                      )),
                  IconButton(
                      onPressed: () {
                        billSearchController.next();
                      },
                      icon: const Icon(Icons.keyboard_double_arrow_left)),
                ],
              ),
            ],
          ),
        ),
        const HorizontalSpace(20),
      ],
    );
  }
}
