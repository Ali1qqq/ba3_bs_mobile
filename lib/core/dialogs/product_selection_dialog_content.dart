import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../widgets/custom_text_field_with_icon.dart';
import '../widgets/pluto_grid_with_app_bar_.dart';

class ProductSelectionDialogContent extends StatelessWidget {
  final List<MaterialModel> searchedMaterials;
  final Function(PlutoGridOnSelectedEvent onSelectedEvent) onRowSelected;

  final void Function(String) onSubmitted;
  final TextEditingController productTextController;

  const ProductSelectionDialogContent({
    super.key,
    required this.searchedMaterials,
    required this.onRowSelected,
    required this.productTextController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(
      builder: (materialController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(15),
                child: PlutoGridWithAppBar(
                  title: 'اختيار مادة',
                  leadingIcon: Icons.close,
                  tableSourceModels: searchedMaterials,
                  onLoaded: (event) {
                    event.stateManager.setShowColumnFilter(true);
                  },
                  onSelected: onRowSelected,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextFieldWithIcon(
                textEditingController: productTextController,
                onSubmitted: onSubmitted,
                onIconPressed: () {},
              ),
            ),
            const VerticalSpace(),
          ],
        );
      },
    );
  }
}