import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../constants/app_constants.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../widgets/custom_text_field_with_icon.dart';
import '../widgets/pluto_grid_with_app_bar_.dart';

Future<MaterialGroupModel?> searchProductGroupTextDialog(String productGroupText) async {
  TextEditingController productGroupTextController = TextEditingController()..text = productGroupText;

  List<MaterialGroupModel> searchedMaterials;

  searchedMaterials = await read<MaterialGroupController>().searchOfProductByText(productGroupTextController.text);

  MaterialGroupModel? selectedMaterial;

  if (searchedMaterials.length == 1) {
    return searchedMaterials.first;
  } else if (searchedMaterials.isEmpty) {
    return null;
  } else {
    await showDialog<String>(
        context: Get.context!,
        builder: (BuildContext context) => Dialog(
              child: GetBuilder<MaterialGroupController>(builder: (materialController) {
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
                              title: 'اختيار المجموعة',
                              tableSourceModels: searchedMaterials,
                              onLoaded: (PlutoGridOnLoadedEvent onLoadedEvent) {},
                              onSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
                                final materialId = onSelectedEvent.row?.cells[AppConstants.materialGroupIdFiled]?.value;
                                if (materialId != null) {
                                  selectedMaterial = materialController.getMaterialGroupById(materialId);
                                  Get.back();
                                }
                              },
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextFieldWithIcon(
                            textEditingController: productGroupTextController,
                            onSubmitted: (_) async {
                              searchedMaterials = await materialController.searchOfProductByText(productGroupTextController.text);
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