import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/bill/ui/widgets/bill_shared/custom_text_field.dart';
import '../constants/app_strings.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../widgets/pluto_grid_with_app_bar_.dart';

Future<MaterialModel?> searchProductTextDialog(String productText) async {
  TextEditingController productTextController = TextEditingController()..text = productText;

  List<MaterialModel> searchedMaterials;

  searchedMaterials = read<MaterialController>().searchOfProductByText(productTextController.text);

  MaterialModel? selectedMaterial;

  if (searchedMaterials.length == 1) {
    return searchedMaterials.first;
  } else if (searchedMaterials.isEmpty) {
    return null;
  } else {
    await showDialog<String>(
        context: Get.context!,
        builder: (BuildContext context) => Dialog(
              child: GetBuilder<MaterialController>(builder: (materialController) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: Get.height / 1.5,
                          child: ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(15),
                            child: PlutoGridWithAppBar(
                              title: 'اختيار مادة',
                              tableSourceModels: searchedMaterials,
                              onLoaded: (PlutoGridOnLoadedEvent onLoadedEvent) {},
                              onSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
                                final materialId = onSelectedEvent.row?.cells[AppStrings.materialIdFiled]?.value;
                                if (materialId != null) {
                                  selectedMaterial = materialController.getMaterialById(materialId);
                                  Get.back();
                                }
                              },
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextFieldWithIcon(
                            controller: productTextController,
                            onSubmitted: (_) async {
                              searchedMaterials = materialController.searchOfProductByText(productTextController.text);
                              materialController.update();
                            },
                            onIconPressed: () {}),
                      ),
                      const VerticalSpace(),
                    ],
                  ),
                );
              }),
            ));

    return selectedMaterial;
  }
}
