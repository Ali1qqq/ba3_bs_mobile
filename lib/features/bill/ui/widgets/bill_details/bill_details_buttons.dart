import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../users_management/data/models/role_model.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../../data/models/bill_model.dart';

class BillDetailsButtons extends StatelessWidget {
  const BillDetailsButtons({
    super.key,
    required this.billDetailsController,
    required this.billDetailsPlutoController,
    required this.billModel,
    required this.fromBillById,
    required this.billSearchController,
  });

  final BillDetailsController billDetailsController;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;
  final BillModel billModel;
  final bool fromBillById;

  @override
  Widget build(BuildContext context) {
    log('isPending ${billSearchController.isPending}');

    return Container(
      width: 1.sw,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          if (billSearchController.isNew) _buildAddButton(),
          if (RoleItemType.viewBill.hasPermission) _buildApprovalOrBondButton(context),
          _buildPrintButton(),
          _buildEInvoiceButton(context),
          if (!billSearchController.isNew) _buildPdfEmailButton(),
          if (!billSearchController.isNew) _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Obx(() {
      return AppButton(
        title: 'إضافة',
        width: 100,
        fontSize: 14,
        color: billDetailsController.isBillSaved.value ? Colors.green : Colors.blue.shade700,
        onPressed: billDetailsController.isBillSaved.value
            ? () {}
            : () async {
                billDetailsController.saveBill(billModel.billTypeModel);
              },
        iconData: Icons.add_chart_outlined,
      );
    });
  }

  Widget _buildApprovalOrBondButton(BuildContext context) {
    if (billSearchController.isPending) {
      return AppButton(
        title: 'قبول',
        width: 100,
        fontSize: 14,
        onPressed: () async {
          billDetailsController.updateBillStatus(billModel, Status.approved);
        },
        iconData: Icons.file_open_outlined,
      );
    } else {
      return AppButton(
        title: 'السند',
        width: 100,
        fontSize: 14,
        onPressed: () async {
          billDetailsController.createEntryBond(billModel, context);
        },
        iconData: Icons.file_open_outlined,
      );
    }
  }

  Widget _buildPrintButton() {
    return AppButton(
      iconData: Icons.print_outlined,
      title: 'طباعة',
      width: 100,
      fontSize: 14,
      onPressed: () async {
        billDetailsController.printBill(
          billModel: billModel,
          invRecords: billDetailsPlutoController.generateRecords,
        );
      },
    );
  }

  Widget _buildEInvoiceButton(BuildContext context) {
    return AppButton(
      title: 'E-Invoice',
      color: Colors.blue.shade700,
      width: 110,
      fontSize: 14,
      onPressed: () {
        billDetailsController.showEInvoiceDialog(billModel, context);
      },
      iconData: Icons.link,
    );
  }

  Widget _buildPdfEmailButton() {
    return AppButton(
      title: 'Pdf-Email',
      width: 120,
      fontSize: 14,
      onPressed: () {
        billDetailsController.generateAndSendBillPdf(billModel);
      },
      iconData: Icons.link,
    );
  }

  Widget _buildDeleteButton() {
    return AppButton(
      iconData: Icons.delete_outline,
      width: 100,
      fontSize: 14,
      color: Colors.red,
      title: 'حذف',
      onPressed: () async {
        billDetailsController.deleteBill(billModel, fromBillById: fromBillById);
      },
    );
  }
}
