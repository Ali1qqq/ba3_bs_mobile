import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_icon_button.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/language_switch_fa_icon.dart';
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
        HorizontalSpace(20),
        CustomIconButton(
          onPressed: () {
            bondSearchController.last();
          },
          disabled: bondSearchController.isLast,
          icon: LanguageSwitchFaIcon(
            iconData: FontAwesomeIcons.arrowRotateRight,
            size: 14,
          ),
        ),
        HorizontalSpace(5),
        CustomIconButton(
          disabled: bondSearchController.isLast,
          onPressed: () {
            bondSearchController.jumpTenForward();
          },
          icon: LanguageSwitchFaIcon(
            iconData: Icons.keyboard_double_arrow_right_outlined,
          ),
        ),
        CustomIconButton(
          disabled: bondSearchController.isLast,
          onPressed: () {
            bondSearchController.next();
          },
          icon: LanguageSwitchFaIcon(
            iconData: Icons.keyboard_arrow_right_outlined,
          ),
        ),
        HorizontalSpace(5),
        SizedBox(
          width: Get.width * 0.10,
          child: CustomTextFieldWithoutIcon(
            isNumeric: true,
            textEditingController: bondDetailsController.bondNumberController,
            onSubmitted: (billNumber) {
              bondSearchController.goToBondByNumber(billNumber.toInt);
            },
          ),
        ),
        HorizontalSpace(5),
        CustomIconButton(
          onPressed: () {
            bondSearchController.previous();
          },
          disabled: bondSearchController.isFirst,
          icon: LanguageSwitchFaIcon(
            iconData: Icons.keyboard_arrow_left_outlined,
          ),
        ),
        CustomIconButton(
          onPressed: () {
            bondSearchController.jumpTenBackward();
          },
          disabled: bondSearchController.isFirst,
          icon: LanguageSwitchFaIcon(
            iconData: Icons.keyboard_double_arrow_left,
          ),
        ),
        HorizontalSpace(5),
        CustomIconButton(
          onPressed: () {
            bondSearchController.first();
          },
          disabled: bondSearchController.isFirst,
          icon: LanguageSwitchFaIcon(
            iconData: FontAwesomeIcons.arrowRotateLeft,
            size: 14,
          ),
        ),
        const HorizontalSpace(20),
      ],
    );
  }
}