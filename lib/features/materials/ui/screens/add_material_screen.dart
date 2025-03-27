import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/searchable_material_field.dart';
import 'package:ba3_bs_mobile/core/widgets/tax_dropdown.dart';
import 'package:ba3_bs_mobile/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../widgets/add_material/add_material_form.dart';

class AddMaterialScreen extends StatelessWidget {
  const AddMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(controller.selectedMaterial?.matName ?? AppStrings.newMaterial.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 20,
            children: [
              AddMaterialForm(
                controller: controller,
              ),
              FormFieldRow(
                firstItem: TaxDropdown(taxSelectionHandler: controller.materialFromHandler),
                secondItem: SearchableMaterialField(
                  label: AppStrings.group.tr,
                  textController: controller.materialFromHandler.parentController,
                  onSubmitted: (text) {
                    controller.openMaterialGroupSelectionDialog(
                      query: text,
                      context: context,
                    );
                  },
                ),
              ),
              AppButton(
                title: controller.selectedMaterial?.id == null ? AppStrings.add.tr : AppStrings.edit.tr,
                onPressed: () {
                  controller.saveOrUpdateMaterial();
                },
                iconData: controller.selectedMaterial?.id == null ? Icons.add : Icons.edit,
                color: controller.selectedMaterial?.id == null ? null : Colors.green,
              ),
              AppButton(
                title: AppStrings.delete.tr,
                onPressed: () {
                  controller.deleteMaterial();
                },
                iconData: Icons.delete,
                color: Colors.red,
              ),
            ],
          ),
        ),
      );
    });
  }
}