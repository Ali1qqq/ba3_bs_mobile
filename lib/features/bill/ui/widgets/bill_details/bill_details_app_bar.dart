import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/services/translation/translation_controller.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/custom_icon_button.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/language_switch_fa_icon.dart';
import '../../../../users_management/data/models/role_model.dart';
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
      leadingWidth: 400.w,
      centerTitle: false,
      title: Text(
        read<TranslationController>().currentLocaleIsRtl ? '${billTypeModel.fullName}' : '${billTypeModel.latinFullName}',
      ),
      actions: [
        Visibility(
          visible: RoleItemType.viewBill.hasAdminPermission,
          child: Row(
            children: [
              HorizontalSpace(15),
              CustomIconButton(
                onPressed: () {
                  billSearchController.tail();
                },
                disabled: billSearchController.isTail,
                icon: LanguageSwitchFaIcon(
                  iconData: FontAwesomeIcons.arrowRotateRight,
                  size: 14,
                ),
              ),
              HorizontalSpace(5),
              CustomIconButton(
                disabled: billSearchController.isTail,
                onPressed: () {
                  billSearchController.jumpForwardByTen();
                },
                icon: LanguageSwitchFaIcon(
                  iconData: Icons.keyboard_double_arrow_right_outlined,
                ),
              ),
              CustomIconButton(
                disabled: billSearchController.isTail,
                onPressed: () {
                  billSearchController.next();
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
                  textEditingController: billDetailsController.billNumberController,
                  onSubmitted: (billNumber) {
                    billSearchController.goToBillByNumber(billNumber.toInt);
                  },
                ),
              ),
              HorizontalSpace(5),
              CustomIconButton(
                onPressed: () {
                  billSearchController.previous();
                },
                disabled: billSearchController.isHead,
                icon: LanguageSwitchFaIcon(
                  iconData: Icons.keyboard_arrow_left_outlined,
                ),
              ),
              CustomIconButton(
                onPressed: () {
                  billSearchController.jumpBackwardByTen();
                },
                disabled: billSearchController.isHead,
                icon: LanguageSwitchFaIcon(
                  iconData: Icons.keyboard_double_arrow_left,
                ),
              ),
              HorizontalSpace(5),
              CustomIconButton(
                onPressed: () {
                  billSearchController.head();
                },
                disabled: billSearchController.isHead,
                icon: LanguageSwitchFaIcon(
                  iconData: FontAwesomeIcons.arrowRotateLeft,
                  size: 14,
                ),
              ),
              HorizontalSpace(15),
            ],
          ),
        ),

        ///this for mobile
        CustomIconButton(
          disabled: false,
          onPressed: () {
            billDetailsController.showBarCodeScanner(context, billTypeModel);
          },
          icon: LanguageSwitchFaIcon(
            iconData: FontAwesomeIcons.barcode,
          ),
        ),
      ],
    );
  }
}