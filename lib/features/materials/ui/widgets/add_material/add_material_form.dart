import 'package:flutter/material.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../../../controllers/material_controller.dart';

class AddMaterialForm extends StatelessWidget {
  final MaterialController controller;
  const AddMaterialForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
        key: controller.materialFromHandler.formKey,
        child: Column(
          spacing: 20,
          children: [
            OrganizedWidget(
                titleWidget: Center(child: Text("معلومات المادة")),
                bodyWidget: Column(
                  spacing: 8,
                  children: [
                    FormFieldRow(
                      firstItem: TextAndExpandedChildField(
                          label: "اسم المادة",
                          child: CustomTextFieldWithoutIcon(
                            filedColor: AppColors.backGroundColor,
                            textEditingController: controller.materialFromHandler.nameController,
                            validator: (value) => controller.materialFromHandler.defaultValidator(value, 'اسم المادة'),
                          )),
                      secondItem: TextAndExpandedChildField(
                          label: "الاسم اللاتيني",
                          child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,
                              textEditingController: controller.materialFromHandler.latinNameController)),
                    ),
                    FormFieldRow(
                      firstItem: TextAndExpandedChildField(
                          label: "رمز المادة",
                          child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,
                              validator: (value) =>
                                  controller.materialFromHandler.defaultValidator(value, 'رمز المادة'),
                              textEditingController: controller.materialFromHandler.codeController)),
                      secondItem: TextAndExpandedChildField(
                          label: "رمز الباركود",
                          child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,
                              validator: (value) =>
                                  controller.materialFromHandler.defaultValidator(value, 'رمز الباركود'),
                              textEditingController: controller.materialFromHandler.barcodeController)),
                    ),
                  ],
                )),
            OrganizedWidget(
                titleWidget: Center(child: Text("الاسعار")),
                bodyWidget: Column(
                  spacing: 8,
                  children: [
                    FormFieldRow(
                      firstItem: TextAndExpandedChildField(
                          label: " المستهلك",
                          child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,
                              validator: (value) => controller.materialFromHandler.defaultValidator(value, 'المستهلك'),
                              textEditingController: controller.materialFromHandler.customerPriceController)),
                      secondItem: TextAndExpandedChildField(
                          label: "المفرق",
                          child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,
                              textEditingController: controller.materialFromHandler.retailPriceController)),
                    ),
                    FormFieldRow(
                      firstItem: TextAndExpandedChildField(
                          label: "الجملة",
                          child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,
                              textEditingController: controller.materialFromHandler.wholePriceController)),
                      secondItem: SizedBox(),
                    ),
                  ],
                ))
          ],
        ));
  }
}
