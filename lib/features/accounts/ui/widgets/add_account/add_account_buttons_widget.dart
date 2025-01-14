import 'package:flutter/cupertino.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/accounts_controller.dart';

class AddAccountButtonsWidget extends StatelessWidget {

  final AccountsController controller;
  const AddAccountButtonsWidget({
    super.key,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Row(
       spacing: 20,
      children: [
        AppButton(
            title: controller.isFromHandler ? 'تعديل' : 'اضافة',
            onPressed: () {
              controller.saveOrUpdateAccount();
            }),
        if(controller.isFromHandler)
          AppButton(
              title: 'حذف',
              onPressed: () {
                controller.deleteAccount();
              }),
      ],
    );
  }
}
