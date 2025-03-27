import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import 'package:ba3_bs_mobile/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/add_seller_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';

class AddSellerScreen extends StatelessWidget {
  const AddSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddSellerController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(controller.selectedSellerModel?.costName ?? AppStrings.newS.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormFieldRow(
                  firstItem: TextAndExpandedChildField(
                    label: AppStrings.name.tr,
                    child: CustomTextFieldWithoutIcon(
                      textEditingController: controller.nameController,
                      suffixIcon: const SizedBox.shrink(),
                    ),
                  ),
                  secondItem: TextAndExpandedChildField(
                    label: AppStrings.code.tr,
                    child: CustomTextFieldWithoutIcon(
                      textEditingController: controller.codeController,
                      suffixIcon: const SizedBox.shrink(),
                    ),
                  )),
              Spacer(),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: .15.sh),
                  child: AppButton(
                    title: controller.selectedSellerModel?.costGuid == null ? AppStrings.add.tr : AppStrings.edit.tr,
                    onPressed: () {
                      controller.saveOrUpdateSeller();
                    },
                    iconData: controller.selectedSellerModel?.costGuid == null ? Icons.add : Icons.edit,
                    color: controller.selectedSellerModel?.costGuid == null ? null : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}