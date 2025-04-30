import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../features/floating_window/services/overlay_service.dart';
import '../../features/materials/data/models/materials/material_model.dart';
import '../constants/app_strings.dart';
import '../widgets/app_button.dart';
import '../widgets/app_spacer.dart';
import '../widgets/custom_text_field_without_icon.dart';

class MaterialTaskCountDialog extends StatelessWidget {
  const MaterialTaskCountDialog({
    super.key,
    required this.searchedMaterials,
    required this.materialTextEditingController,
  });

  final List<MaterialModel> searchedMaterials;
  final TextEditingController materialTextEditingController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(searchedMaterials.first.matName!),
          VerticalSpace(),
          TextAndExpandedChildField(
              label: AppStrings.quantity.tr,
              child: CustomTextFieldWithoutIcon(
                textEditingController: materialTextEditingController,
                onSubmitted: (_) {
                  OverlayService.back();
                },
              )),
          AppButton(
            title: AppStrings.add.tr,
            onPressed: () {
              OverlayService.back();
            },
          )
        ],
      ),
    );
  }
}
