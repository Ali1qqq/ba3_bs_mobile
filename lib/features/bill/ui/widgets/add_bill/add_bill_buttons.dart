import 'package:ba3_bs_mobile/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../patterns/data/models/bill_type_model.dart';

class AddBillButtons extends StatelessWidget {
  const AddBillButtons({
    super.key,
    required this.addBillController,
    required this.billTypeModel,
  });

  final AddBillController addBillController;
  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 20,
        runSpacing: 20,
        children: [
          Obx(() {
            final bool showAddNewBillButton = addBillController.isAddNewBillButtonVisible.value;
            return showAddNewBillButton
                ? AppButton(
                    title: 'جديد',
                    height: 20,
                    onPressed: () async {
                      addBillController.resetBillForm();
                    },
                    iconData: Icons.add_chart_outlined)
                : AppButton(
                    title: 'إضافة',
                    height: 20,
                    onPressed: () async {
                      addBillController.saveBill(billTypeModel);
                    },
                    iconData: Icons.add_chart_outlined);
          }),
          AppButton(
              title: 'السند',
              height: 20,
              onPressed: () async {
                addBillController.createBond(billTypeModel, context);
              },
              iconData: Icons.file_open_outlined),
          ...[
            AppButton(
              iconData: Icons.print_outlined,
              title: 'طباعة',
              height: 20,
              onPressed: () async {
                addBillController.printBill(read<AddBillPlutoController>().generateRecords);
              },
            ),
            Obx(() {
              final bool showAddNewBillButton = addBillController.isAddNewBillButtonVisible.value;
              return showAddNewBillButton
                  ? AppButton(
                      title: 'E-Invoice',
                      height: 20,
                      onPressed: () => addBillController.showEInvoice(context),
                      iconData: Icons.link,
                    )
                  : const SizedBox.shrink();
            }),
          ],
        ],
      ),
    );
  }
}
