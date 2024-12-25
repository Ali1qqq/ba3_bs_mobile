import 'package:ba3_bs_mobile/core/helper/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../controllers/bonds/bond_details_controller.dart';
import '../../../controllers/bonds/bond_search_controller.dart';

class BondDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BondDetailsAppBar({
    super.key,
    required this.bondDetailsController,
    required this.bondSearchController,
    required this.bondTypeModel,
  });

  final BondDetailsController bondDetailsController;
  final BondSearchController bondSearchController;
  final BondType bondTypeModel;

  // kToolbarHeight: default AppBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      title: Text(bondTypeModel.value),
      actions: [
        IconButton(
            onPressed: () {
              bondSearchController.previous();
            },
            icon: const Icon(Icons.keyboard_double_arrow_right)),
        SizedBox(
          width: Get.width * 0.10,
          child: CustomTextFieldWithoutIcon(
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textEditingController: bondDetailsController.bondNumberController,
            onSubmitted: (bondNumber) {
              bondSearchController.goToBondByNumber(bondNumber.toInt);
            },
          ),
        ),
        IconButton(
            onPressed: () {
              bondSearchController.next();
            },
            icon: const Icon(Icons.keyboard_double_arrow_left)),
      ],
    );
  }
}
