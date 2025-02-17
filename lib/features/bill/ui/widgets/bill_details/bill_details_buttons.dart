import 'package:ba3_bs_mobile/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
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
    required this.billSearchController,
    required this.billModel,
  });

  final BillDetailsController billDetailsController;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;
  final BillModel billModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: 1.sw,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildAddButton(),
            if ((!billSearchController.isNew && RoleItemType.viewBill.hasAdminPermission) &&
                (billModel.billTypeModel.billPatternType!.hasCashesAccount || billSearchController.isPending))
              _buildApprovalOrBondButton(context),
            if (!billSearchController.isPending)
              _buildActionButton(
                title: AppStrings.print.tr,
                icon: Icons.print_outlined,
                onPressed: () => billDetailsController.printBill(
                  context: context,
                  billModel: billModel,
                  invRecords: billDetailsPlutoController.generateRecords,
                ),
              ),
            if (!billSearchController.isPending)
              _buildActionButton(
                title: AppStrings.eInvoice.tr,
                icon: Icons.link,
                onPressed: () => billDetailsController.showEInvoiceDialog(billModel, context),
              ),
            if (!billSearchController.isNew) ..._buildEditDeletePdfButtons(),
            Obx(() => !billDetailsController.isCash
                ? AppButton(
                    height: 20,
                    fontSize: 14,
                    title: AppStrings.more.tr,
                    onPressed: () {
                      billDetailsController.openFirstPayDialog(context);
                    })
                : SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Obx(() {
      final isBillSaved = billDetailsController.isBillSaved.value;
      return AppButton(
        title: isBillSaved ? AppStrings.newS.tr : AppStrings.add.tr,
        height: 20,
        fontSize: 14,
        color: isBillSaved ? Colors.green : Colors.blue.shade700,
        onPressed: isBillSaved
            ? () => billDetailsController.appendNewBill(
                billTypeModel: billModel.billTypeModel, lastBillNumber: billSearchController.bills.last.billDetails.billNumber!)
            : () => billDetailsController.saveBill(billModel.billTypeModel),
        iconData: Icons.add_chart_outlined,
      );
    });
  }

  Widget _buildApprovalOrBondButton(BuildContext context) {
    final isPending = billSearchController.isPending;
    return _buildActionButton(
      title: isPending ? AppStrings.approve.tr : AppStrings.bond.tr,
      icon: Icons.file_open_outlined,
      color: isPending ? Colors.orange : null,
      onPressed: isPending
          ? () => billDetailsController.updateBillStatus(billModel, Status.approved)
          : () => billDetailsController.createEntryBond(billModel, context),
    );
  }

  List<Widget> _buildEditDeletePdfButtons() {
    return [
      if (!billSearchController.isPending)
        _buildActionButton(
          title: AppStrings.edit.tr,
          icon: Icons.edit_outlined,
          onPressed: () => billDetailsController.updateBill(
            billModel: billModel,
            billTypeModel: billModel.billTypeModel,
          ),
        ),
      if (RoleItemType.viewBill.hasAdminPermission && !billSearchController.isPending)
        _buildActionButton(
          title: AppStrings.pdfEmail.tr,
          icon: Icons.link,
          onPressed: () => billDetailsController.generateAndSendBillPdf(billModel),
        ),
      if (RoleItemType.viewBill.hasAdminPermission)
        _buildActionButton(
          title: AppStrings.delete.tr,
          icon: Icons.delete_outline,
          color: Colors.red,
          onPressed: () => billDetailsController.deleteBill(billModel),
        ),
    ];
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    double? width,
  }) {
    return AppButton(
      title: title,
      iconData: icon,
      height: 20,
      width: width ?? 90,
      fontSize: 14,
      color: color ?? Colors.blue.shade700,
      onPressed: onPressed,
    );
  }
}