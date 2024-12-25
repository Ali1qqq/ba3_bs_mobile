import 'dart:developer';

import 'package:ba3_bs_mobile/core/dialogs/account_selection_dialog_content.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/accounts/controllers/accounts_controller.dart';
import '../../features/floating_window/services/overlay_service.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../i_controllers/i_recodes_pluto_controller.dart';

class GetAccountsByEnterAction extends PlutoGridShortcutAction {
  const GetAccountsByEnterAction({
    required this.plutoController,
    required this.textFieldName,
    required this.context,
  });

  final IRecodesPlutoController plutoController;
  final String textFieldName;
  final BuildContext context;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) async {
    await getAccounts(stateManager, plutoController, textFieldName);
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

  /// Handles account selection and updates the grid cell value.
  Future<void> getAccounts(
    PlutoGridStateManager stateManager,
    IRecodesPlutoController plutoController,
    String textFieldName,
  ) async {
    final columnField = stateManager.currentColumn?.field;

    if (columnField != textFieldName) return;

    final accountsController = read<AccountsController>();
    final query = stateManager.currentCell?.value ?? '';

    List<AccountModel> searchedAccounts = accountsController.getAccounts(query);
    AccountModel? selectedAccountModel;

    if (searchedAccounts.length == 1) {
      // Single match
      selectedAccountModel = searchedAccounts.first;
      updateWithSelectedAccount(selectedAccountModel, stateManager, plutoController, columnField!);
    } else if (searchedAccounts.isEmpty) {
      // No matches
      _resetCellValue(stateManager, columnField);

      updateWithSelectedAccount(null, stateManager, plutoController, columnField!);
    } else {
      // Multiple matches, show search dialog
      _showSearchDialog(
        columnField: columnField!,
        stateManager: stateManager,
        controller: plutoController,
        searchedAccounts: searchedAccounts,
      );
    }
  }

  void _showSearchDialog({
    required List<AccountModel> searchedAccounts,
    required PlutoGridStateManager stateManager,
    required IRecodesPlutoController controller,
    required String columnField,
  }) {
    OverlayService.showDialog(
      context: context,
      title: 'أختر الحساب',
      content: AccountSelectionDialogContent(
        accounts: searchedAccounts,
        onAccountTap: (selectedAccount) {
          OverlayService.back();

          updateWithSelectedAccount(selectedAccount, stateManager, plutoController, columnField);
        },
      ),
      onCloseCallback: () {
        log('Account Selection Dialog Closed.');
      },
    );
  }

  void updateWithSelectedAccount(
    AccountModel? accountModel,
    PlutoGridStateManager stateManager,
    IRecodesPlutoController plutoController,
    String columnField,
  ) {
    if (accountModel != null) {
      _updateCellValue(stateManager, columnField, accountModel.accName);
    } else {
      _resetCellValue(stateManager, columnField);
    }

    stateManager.notifyListeners();
    plutoController.update();
  }

  /// Updates the value of the current cell.
  void _updateCellValue(PlutoGridStateManager stateManager, String? columnField, String? newValue) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[columnField]!,
      newValue,
      force: true,
      callOnChangedEvent: true,
      notify: true,
    );
  }

  /// Resets the value of the current cell to its original state.
  void _resetCellValue(PlutoGridStateManager stateManager, String? columnField) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[columnField]!,
      stateManager.currentCell?.value,
      callOnChangedEvent: false,
      notify: true,
    );
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
}
