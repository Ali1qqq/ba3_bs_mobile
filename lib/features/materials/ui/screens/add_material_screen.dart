import 'package:ba3_bs_mobile/core/widgets/searchable_material_field.dart';
import 'package:ba3_bs_mobile/core/widgets/tax_dropdown.dart';
import 'package:ba3_bs_mobile/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          title: Text(controller.selectedMaterial?.matName ?? 'مادة جديد'),
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
                  label: "المجموعة",
                  textController: controller.materialFromHandler.parentController,
                  onSubmitted: (text) {
                    controller.openMaterialSelectionDialog(
                      query: text,
                      context: context,
                    );
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: .15.sh),
                  child: AppButton(
                    title: controller.selectedMaterial?.id == null ? 'إضافة' : 'تعديل',
                    onPressed: () {
                      controller.saveOrUpdateMaterial();
                    },
                    iconData: controller.selectedMaterial?.id == null ? Icons.add : Icons.edit,
                    color: controller.selectedMaterial?.id == null ? null : Colors.green,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
