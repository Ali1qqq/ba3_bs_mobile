import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../data/models/cheques_model.dart';

class AddChequeButtons extends StatelessWidget {
  const AddChequeButtons({
    super.key,
    required this.chequesDetailsController,
    required this.chequesSearchController,
    required this.chequesType,
    required this.chequesModel,
  });

  final ChequesDetailsController chequesDetailsController;
  final ChequesSearchController chequesSearchController;
  final ChequesType chequesType;
  final ChequesModel chequesModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(runAlignment: WrapAlignment.center, runSpacing: 20, spacing: 20, children: [
        if (chequesSearchController.isNew)
          Obx(() {
            return AppButton(
                title: 'إضافة',
                height: 20,
                color: chequesDetailsController.isChequesSaved.value ? Colors.green : Colors.blue.shade700,
                onPressed: chequesDetailsController.isChequesSaved.value
                    ? () {}
                    : () async {
                  await chequesDetailsController.saveCheques(chequesType);
                },
                iconData: Icons.add_chart_outlined);
          }),
        if (!chequesSearchController.isNew) ...[
          AppButton(
            title: "تعديل",
            height: 20,
            onPressed: () async {
              chequesDetailsController.updateCheques(
                chequesModel: chequesModel,
                chequesType: chequesType,
              );
            },
            iconData: Icons.edit_outlined,
          ),
          AppButton(
            onPressed: () {
              chequesDetailsController.deleteCheques(chequesModel);
            },
            title: "حذف",
            iconData: Icons.delete_outline,
            color: Colors.red,
          ),
          AppButton(
            onPressed: () {
              chequesDetailsController.launchEntryBondWindow(chequesModel, context);
            },
            title: "السند",
            iconData: Icons.view_list_outlined,
          ),
          if (!chequesDetailsController.isRefundPay!)
            AppButton(
              onPressed: () async {
                chequesDetailsController.isPayed!
                    ? chequesDetailsController.clearPayCheques(chequesModel)
                    : chequesDetailsController.savePayCheques(chequesModel);
              },
              title: chequesDetailsController.isPayed! ? "حذف الدفع" : "دفع",
              color:chequesDetailsController.isPayed!
                  ?Colors.red: Colors.black,
              iconData: Icons.paid,
            ),
          if (chequesDetailsController.isPayed!)
            AppButton(
              onPressed: () {
                chequesDetailsController.launchPayEntryBondWindow(chequesModel, context);
              },
              title: "سند الدفع",
              iconData: Icons.view_list_outlined,
            ),
          if (!chequesDetailsController.isPayed!)
            AppButton(
              onPressed: () {
                chequesDetailsController.isRefundPay!
                    ? chequesDetailsController.deleteRefundPayCheques(chequesModel)
                    : chequesDetailsController.refundPayCheques(chequesModel);
              },
              title: chequesDetailsController.isRefundPay! ? "حذف الاسترداد" : "استرداد",
              iconData: Icons.lock_reset_rounded,
              color:chequesDetailsController.isRefundPay!
                  ?Colors.red: Colors.grey,
            ),
          if (chequesDetailsController.isRefundPay!)
            AppButton(
              onPressed: () {
                chequesDetailsController.launchRefundPayEntryBondWindow(chequesModel, context);
              },
              title: "السند المسترد",
              iconData: Icons.lock_reset_rounded,
            ),
        ]
      ]),
    );
  }
}
