import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_items.dart';
import 'package:ba3_bs_mobile/features/bill/ui/widgets/bill_details/add_serial_widget.dart';
import 'package:ba3_bs_mobile/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/mats_statement_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../materials/data/models/materials/material_model.dart';
import 'bill_pluto_grid_service.dart';
import 'bill_pluto_utils.dart';

class BillPlutoContextMenu {
  final IPlutoController plutoController;

  BillPlutoContextMenu(this.plutoController);

  void showPriceTypeMenu({
    required BuildContext context,
    required Offset tapPosition,
    required MaterialModel materialModel,
    required BillPlutoUtils invoiceUtils,
    required BillPlutoGridService gridService,
    required int index,
    required BillTypeModel billTypeModel,
    required PlutoRow row,
  }) {
    OverlayService.showPopupMenu(
      context: context,
      tapPosition: tapPosition,
      items: PriceType.values,
      itemLabelBuilder: (type) => '${type.label}: ${invoiceUtils.getPrice(type: type, materialModel: materialModel).toStringAsFixed(2)}',
      onSelected: (PriceType type) {
        final PlutoRow selectedRow = row;
        final int quantity = AppServiceUtils.getItemQuantity(selectedRow);

        gridService.updateInvoiceValuesBySubTotal(
          selectedRow: selectedRow,
          subTotal: invoiceUtils.getPrice(type: type, materialModel: materialModel),
          quantity: quantity,
          billTypeModel: billTypeModel,
        );
        plutoController.update();
      },
      onCloseCallback: () {
        debugPrint('PriceType menu closed.');
      },
    );
  }

  void showMaterialMenu({
    required List<String> materialMenu,
    required BuildContext context,
    required Offset tapPosition,
    required MaterialModel materialModel,
    required BillPlutoUtils invoiceUtils,
    required BillPlutoGridService gridService,
    required BillItem billItem,
    required int index,
  }) {
    OverlayService.showPopupMenu(
      context: context,
      tapPosition: tapPosition,
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
      items: materialMenu,
      itemLabelBuilder: (item) => item,
      onSelected: (String selectedMenuItem) {
        if (selectedMenuItem == 'حركة المادة') {
          read<MaterialsStatementController>().fetchMatStatements(materialModel, context: context);
        }

        if (selectedMenuItem == 'إضافة serial') {
          final PlutoRow selectedRow = plutoController.recordsTableStateManager.rows[index];
          final String matQuantity = AppServiceUtils.getCellValue(selectedRow, AppConstants.invRecQuantity);
          debugPrint('matQuantity $matQuantity');
          OverlayService.showDialog(
            context: context,
            content: AddSerialWidget(
              plutoController: plutoController,
              billItem: billItem,
              materialModel: materialModel,
              serialCount: int.tryParse(matQuantity) ?? 0,
            ),
            onCloseCallback: () {
              final List<TextEditingController> serialsControllers = plutoController.buyMaterialsSerialsControllers[materialModel] ?? [];

              if (serialsControllers.isNotEmpty && !AppConstants.hideInvRecProductSerialNumbers) {
                // Extract serial numbers from controllers
                final List<String> serialNumbers =
                    serialsControllers.map((controller) => controller.text.trim()).where((text) => text.isNotEmpty).toList();

                // Update the cell value with the extracted serial numbers
                gridService.updateSelectedRowCellValue(
                  plutoController.recordsTableStateManager,
                  selectedRow,
                  AppConstants.invRecProductSerialNumbers,
                  serialNumbers,
                );
              }

              debugPrint('Material serial dialog closed. Serial Numbers: ${serialsControllers.map((c) => c.text).toList()}');
            },
          );
        }
      },
      onCloseCallback: () {
        debugPrint('Material Menu closed.');
      },
    );
  }

  void showDeleteConfirmationDialog(int index, BuildContext context) {
    OverlayService.showDialog(
      context: context,
      width: 280,
      height: 160,
      showDivider: false,
      borderRadius: BorderRadius.circular(20),
      title: AppConstants.deleteConfirmationTitle,
      content: Column(
        children: [
          const Spacer(),
          const Text(AppConstants.deleteConfirmationMessage),
          const VerticalSpace(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppButton(
                title: AppConstants.yes,
                onPressed: () => _deleteRow(index),
                color: Colors.red,
                iconData: Icons.check,
                width: 80,
              ),
              const HorizontalSpace(20),
              const AppButton(
                title: AppConstants.no,
                onPressed: OverlayService.back,
                iconData: Icons.clear,
                width: 80,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteRow(int rowIdx) {
    final rowToRemove = plutoController.recordsTableStateManager.rows[rowIdx];
    plutoController.recordsTableStateManager.removeRows([rowToRemove]);
    OverlayService.back();
    plutoController.update();
  }
}