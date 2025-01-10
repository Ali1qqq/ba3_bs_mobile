import 'package:ba3_bs_mobile/core/helper/extensions/bisc/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../controllers/cheques/cheques_details_controller.dart';
import '../../../controllers/cheques/cheques_search_controller.dart';

class ChequesDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChequesDetailsAppBar({
    super.key,
    required this.chequesDetailsController,
    required this.chequesSearchController,
    required this.chequesTypeModel,
  });

  final ChequesDetailsController chequesDetailsController;
  final ChequesSearchController chequesSearchController;
  final ChequesType chequesTypeModel;

  // kToolbarHeight: default AppBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      title: Text(chequesTypeModel.value),
      actions: [
        IconButton(
            onPressed: () {
              chequesSearchController.previous();
            },
            icon: const Icon(Icons.keyboard_double_arrow_right)),
        SizedBox(
          width: Get.width * 0.10,
          child: CustomTextFieldWithoutIcon(
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textEditingController: chequesDetailsController.chequesNumberController,
            onSubmitted: (chequesNumber) {
              chequesSearchController.goToChequesByNumber(chequesNumber.toInt);
            },
          ),
        ),
        IconButton(
            onPressed: () {
              chequesSearchController.next();
            },
            icon: const Icon(Icons.keyboard_double_arrow_left)),
      ],
    );
  }
}
