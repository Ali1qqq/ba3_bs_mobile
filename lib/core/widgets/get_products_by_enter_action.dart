import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/floating_window/services/overlay_service.dart';
import '../../features/materials/controllers/material_controller.dart';
import '../dialogs/product_selection_dialog_content.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../i_controllers/i_pluto_controller.dart';

class GetProductByEnterAction extends PlutoGridShortcutAction {
  const GetProductByEnterAction(this.controller, this.context);

  final IPlutoController controller;
  final BuildContext context;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) async {
    getProduct(stateManager, controller);
    // In SelectRow mode, the current Row is passed to the onSelected callback.
    if (stateManager.mode.isSelectMode && stateManager.onSelected != null) {
      stateManager.onSelected!(PlutoGridOnSelectedEvent(
        row: stateManager.currentRow,
        rowIdx: stateManager.currentRowIdx,
        cell: stateManager.currentCell,
        selectedRows: stateManager.mode.isMultiSelectMode ? stateManager.currentSelectingRows : null,
      ));
      return;
    }

    if (stateManager.configuration.enterKeyAction.isNone) {
      return;
    }

    if (!stateManager.isEditing && _isExpandableCell(stateManager)) {
      stateManager.toggleExpandedRowGroup(rowGroup: stateManager.currentRow!);
      return;
    }

    if (stateManager.configuration.enterKeyAction.isToggleEditing) {
      stateManager.toggleEditing(notify: false);
    } else {
      if (stateManager.isEditing == true || stateManager.currentColumn?.enableEditingMode == false) {
        final saveIsEditing = stateManager.isEditing;

        _moveCell(keyEvent, stateManager);

        stateManager.setEditing(saveIsEditing, notify: false);
      } else {
        stateManager.toggleEditing(notify: false);
      }
    }

    if (stateManager.autoEditing) {
      stateManager.setEditing(true, notify: false);
    }

    stateManager.notifyListeners();
  }

  void getProduct(PlutoGridStateManager stateManager, IPlutoController plutoController) {
    if (stateManager.currentColumn?.field != AppConstants.invRecProduct) return;

    // Initialize variables
    final productText = stateManager.currentCell?.value ?? '';
    final productTextController = TextEditingController()..text = productText;
    final materialController = read<MaterialController>();

    // Search for matching materials
    var searchedMaterials = materialController.searchOfProductByText(productText);
    MaterialModel? selectedMaterial;

    if (searchedMaterials.length == 1) {
      // Single match
      selectedMaterial = searchedMaterials.first;
      updateWithSelectedMaterial(selectedMaterial, stateManager, plutoController);
    } else if (searchedMaterials.isEmpty) {
      // No matches
      updateWithSelectedMaterial(null, stateManager, plutoController);
    } else {
      // Clear focus from PlutoWithEdite before showing the dialog
      FocusScope.of(context).unfocus();

      // Multiple matches, show search dialog
      _showSearchDialog(
        productTextController: productTextController,
        searchedMaterials: searchedMaterials,
        materialController: materialController,
        stateManager: stateManager,
        plutoController: plutoController,
      );
    }
  }

  void _showSearchDialog({
    required TextEditingController productTextController,
    required List<MaterialModel> searchedMaterials,
    required MaterialController materialController,
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
  }) {
    OverlayService.showDialog(
      context: context,
      height: .7.sh,
      width: .8.sw,
      content: ProductSelectionDialogContent(
        searchedMaterials: searchedMaterials,
        onRowSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
          final materialId = onSelectedEvent.row?.cells['الرقم التعريفي']?.value;

          final selectedMaterial = materialId != null ? materialController.getMaterialById(materialId) : null;

          updateWithSelectedMaterial(selectedMaterial, stateManager, plutoController);

          OverlayService.back();
        },
        onSubmitted: (_) {
          searchedMaterials = materialController.searchOfProductByText(productTextController.text);
          materialController.update();
        },
        productTextController: productTextController,
      ),
      onCloseCallback: () {
        log('Product Selection Dialog Closed.');
      },
    );
  }

  void updateWithSelectedMaterial(
    MaterialModel? materialModel,
    PlutoGridStateManager stateManager,
    IPlutoController plutoController,
  ) {
    if (materialModel != null) {
      _updateRowWithMaterial(materialModel, stateManager);
      plutoController.moveToNextRow(stateManager, AppConstants.invRecProduct);
    } else {
      plutoController.restoreCurrentCell(stateManager);
    }

    stateManager.notifyListeners();
    plutoController.update();
  }

  void _updateRowWithMaterial(MaterialModel materialModel, PlutoGridStateManager stateManager) {
    updateCellValue(stateManager, AppConstants.invRecProduct, materialModel.matName);
    updateCellValue(stateManager, AppConstants.invRecSubTotal, materialModel.endUserPrice);
    updateCellValue(stateManager, AppConstants.invRecQuantity, 1);
  }

  bool _isExpandableCell(PlutoGridStateManager stateManager) {
    return stateManager.currentCell != null &&
        stateManager.enabledRowGroups &&
        stateManager.rowGroupDelegate?.isExpandableCell(stateManager.currentCell!) == true;
  }

  void _moveCell(
    PlutoKeyManagerEvent keyEvent,
    PlutoGridStateManager stateManager,
  ) {
    final enterKeyAction = stateManager.configuration.enterKeyAction;

    if (enterKeyAction.isNone) {
      return;
    }

    // تحقق مما إذا كان في الخلية الأخيرة
    bool isLastCellInRow = stateManager.currentColumn?.field == stateManager.columns.last.field;
    bool isLastRow = stateManager.currentRowIdx == stateManager.rows.length - 1;

    if (enterKeyAction.isEditingAndMoveDown || enterKeyAction.isEditingAndMoveRight) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        // الانتقال للأعلى إذا كان Shift مضغوط
        stateManager.moveCurrentCell(
          PlutoMoveDirection.up,
          force: true,
          notify: true,
        );
      } else if (isLastCellInRow && !isLastRow) {
        // إذا كانت الخلية الأخيرة في السطر الحالي، انتقل إلى بداية السطر التالي
        stateManager.setCurrentCell(
          stateManager.rows[stateManager.currentRowIdx! + 1].cells[stateManager.columns.first.field],
          stateManager.currentRowIdx! + 1,
          notify: true,
        );
      } else {
        // إذا لم تكن في آخر خلية، انتقل إلى الخلية التالية
        stateManager.moveCurrentCell(
          PlutoMoveDirection.right,
          force: true,
          notify: true,
        );
      }
    } else if (enterKeyAction.isEditingAndMoveRight) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        // الانتقال لليمين إذا كان Shift مضغوط
        stateManager.moveCurrentCell(
          PlutoMoveDirection.right,
          force: true,
          notify: false,
        );
      } else if (isLastCellInRow && !isLastRow) {
        // إذا كانت الخلية الأخيرة في السطر، انتقل إلى بداية السطر التالي
        stateManager.setCurrentCell(
          stateManager.rows[stateManager.currentRowIdx! + 1].cells[stateManager.columns.first.field],
          stateManager.currentRowIdx! + 1,
          notify: true,
        );
      } else {
        // الانتقال لليمين إذا لم تكن في آخر خلية
        stateManager.moveCurrentCell(
          PlutoMoveDirection.right,
          force: true,
          notify: false,
        );
      }
    }
  }

  void updateCellValue(PlutoGridStateManager stateManager, String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: true,
      notify: true,
      force: true,
    );
  }
}
