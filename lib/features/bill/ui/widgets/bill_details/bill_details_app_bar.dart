import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/language_switch_fa_icon.dart';
import '../../../controllers/bill/bill_details_controller.dart';

class BillDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BillDetailsAppBar({
    super.key,
    required this.billDetailsController,
    required this.billSearchController,
    required this.billTypeModel,
  });

  final BillDetailsController billDetailsController;
  final BillSearchController billSearchController;
  final BillTypeModel billTypeModel;

  // kToolbarHeight: default AppBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 500.w,
      leading: Row(
        children: [
          Visibility(
            visible: RoleItemType.viewBill.hasAdminPermission,
            child: Row(
              children: [
                HorizontalSpace(15),
                LanguageSwitchFaIcon(
                  iconData: FontAwesomeIcons.arrowRotateRight,
                  size: 14,
                  onPressed: () {
                    billSearchController.tail();
                  },
                  disabled: billSearchController.isTail,
                ),
                HorizontalSpace(8),
                LanguageSwitchFaIcon(
                  disabled: billSearchController.isTail,
                  onPressed: () {
                    billSearchController.jumpForwardByTen();
                  },
                  iconData: Icons.keyboard_double_arrow_right_outlined,
                ),
                HorizontalSpace(8),
                LanguageSwitchFaIcon(
                  iconData: Icons.keyboard_arrow_right_outlined,
                  disabled: billSearchController.isTail,
                  onPressed: () {
                    billSearchController.next();
                  },
                ),
                HorizontalSpace(8),
                SizedBox(
                  width: 30.w,
                  height: AppConstants.constHeightTextField,
                  child: CustomTextFieldWithoutIcon(
                    isNumeric: true,
                    textEditingController: billDetailsController.billNumberController,
                    onSubmitted: (billNumber) {
                      billSearchController.goToBillByNumber(billNumber.toInt);
                    },
                  ),
                ),
                HorizontalSpace(8),
                LanguageSwitchFaIcon(
                  iconData: Icons.keyboard_arrow_left_outlined,
                  onPressed: () {
                    billSearchController.previous();
                  },
                  disabled: billSearchController.isHead,
                ),
                HorizontalSpace(8),
                LanguageSwitchFaIcon(
                  onPressed: () {
                    billSearchController.jumpBackwardByTen();
                  },
                  disabled: billSearchController.isHead,
                  iconData: Icons.keyboard_double_arrow_left,
                ),
                HorizontalSpace(8),
                LanguageSwitchFaIcon(
                  onPressed: () {
                    billSearchController.head();
                  },
                  size: 14,
                  disabled: billSearchController.isHead,
                  iconData: FontAwesomeIcons.arrowRotateLeft,
                ),
                HorizontalSpace(8),
              ],
            ),
          ),
        ],
      ),
      actions: [
        HorizontalSpace(15),
        Text('${billTypeModel.fullName}'),
        HorizontalSpace(15),
        LanguageSwitchFaIcon(
          disabled: false,
          onPressed: () {
            billDetailsController.showBarCodeScanner(context, billTypeModel);
          },
          iconData: FontAwesomeIcons.barcode,
        ),
        HorizontalSpace(15),
      ],
    );
  }
}