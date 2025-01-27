import 'package:ba3_bs_mobile/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:flutter/material.dart';
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
    required this.billSearchController,
    required this.billModel,
    required this.fromBillById,
  });

  final BillDetailsController billDetailsController;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;
  final BillModel billModel;
  final bool fromBillById;

  @override
  Widget build(BuildContext context) {
    // log('isPending: ${billSearchController.isPending}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          if (billSearchController.isNew) _buildAddButton(),
          if (!billSearchController.isNew && RoleItemType.viewBill.hasAdminPermission)
            if (billModel.billTypeModel.billPatternType!.hasCashesAccount || billSearchController.isPending)
              _buildApprovalOrBondButton(context),
          _buildActionButton(
            title: 'طباعة',
            icon: Icons.print_outlined,
            onPressed: () => billDetailsController.printBill(
              context: context,
              billModel: billModel,
              invRecords: billDetailsPlutoController.generateRecords,
            ),
          ),
          _buildActionButton(
            title: 'E-Invoice',
            icon: Icons.link,
            onPressed: () => billDetailsController.showEInvoiceDialog(billModel, context),
          ),
          if (!billSearchController.isNew) ..._buildEditDeletePdfButtons(),
          Obx(() => !billDetailsController.isCash
              ? AppButton(
                  height: 20,
                  width: 100,
                  fontSize: 14,
                  title: "المزيد",
                  onPressed: () {
                    billDetailsController.openFirstPayDialog(context);
                  })
              : SizedBox.shrink())
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Obx(() {
      final isBillSaved = billDetailsController.isBillSaved.value;
      return AppButton(
        title: 'إضافة',
        height: 20,
        width: 100,
        fontSize: 14,
        color: isBillSaved ? Colors.green : Colors.blue.shade700,
        onPressed: isBillSaved ? () {} : () => billDetailsController.saveBill(billModel.billTypeModel),
        iconData: Icons.add_chart_outlined,
      );
    });
  }

  Widget _buildApprovalOrBondButton(BuildContext context) {
    final isPending = billSearchController.isPending;
    return _buildActionButton(
      title: isPending ? 'قبول' : 'السند',
      icon: Icons.file_open_outlined,
      color: isPending ? Colors.orange : null,
      onPressed: isPending
          ? () => billDetailsController.updateBillStatus(billModel, Status.approved)
          : () => billDetailsController.createEntryBond(billModel, context),
    );
  }

  List<Widget> _buildEditDeletePdfButtons() {
    return [
      _buildActionButton(
        title: 'تعديل',
        icon: Icons.edit_outlined,
        onPressed: () => billDetailsController.updateBill(
          billModel: billModel,
          billTypeModel: billModel.billTypeModel,
        ),
      ),
      if (RoleItemType.viewBill.hasAdminPermission)
        _buildActionButton(
          title: 'Pdf-Email',
          icon: Icons.link,
          onPressed: () => billDetailsController.generateAndSendBillPdf(billModel),
        ),
      if (RoleItemType.viewBill.hasAdminPermission)
        _buildActionButton(
          title: 'حذف',
          icon: Icons.delete_outline,
          color: Colors.red,
          onPressed: () => billDetailsController.deleteBill(billModel, fromBillById: fromBillById),
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
      width: width ?? 100,
      fontSize: 14,
      color: color ?? Colors.blue.shade700,
      onPressed: onPressed,
    );
  }
}
