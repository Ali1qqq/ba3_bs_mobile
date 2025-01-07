import 'dart:developer';

import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bill_model.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillSearchController extends GetxController {
  late List<BillModel> bills;
  late BillModel currentBill;
  late int currentBillIndex;

  late BillDetailsController billDetailsController;
  late BillDetailsPlutoController billDetailsPlutoController;

  /// Initializes the bill search with the given bills and current bill
  void initialize({
    required List<BillModel> allBills,
    required BillModel currentBill,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
  }) {
    bills = allBills;

    currentBillIndex = bills.indexWhere((current) => current.billId == currentBill.billId || current == currentBill);
    currentBill = bills[currentBillIndex];

    this.billDetailsController = billDetailsController;
    this.billDetailsPlutoController = billDetailsPlutoController;

    _setCurrentBill(currentBillIndex);

    // log('bills length ${bills.length}, currentBillIndex $currentBillIndex, currentBillNumber ${currentBill.billDetails.billNumber}');
  }

  /// Gets the current bill
  BillModel get getCurrentBill => bills[currentBillIndex];

  /// Finds the index of the bill with the given number
  int _getBillIndexByNumber(int? billNumber) => bills.indexWhere((bill) => bill.billDetails.billNumber == billNumber);

  /// Updates the bill in the search results if it exists
  void updateBill(BillModel updatedBill) {
    final billIndex = _getBillIndexByNumber(updatedBill.billDetails.billNumber);

    if (billIndex != -1) {
      bills[billIndex] = updatedBill;

      // Update the current bill if the index matches.
      if (currentBillIndex == billIndex) {
        currentBill = updatedBill;
      }

      update();
    }
  }

  /// Deletes the bill in the search results if it exists
  void removeBill(BillModel billToDelete) {
    final billIndex = _getBillIndexByNumber(billToDelete.billDetails.billNumber);

    if (billIndex != -1) {
      bills.removeAt(billIndex);
      reloadCurrentBill();

      update();
    }
  }

  /// Validates whether the given bill number is within range
  bool _isValidBillNumber(int? billNumber) =>
      billNumber != null && billNumber >= bills.first.billDetails.billNumber! && billNumber <= bills.last.billDetails.billNumber!;

  /// Handles invalid bill number cases by showing appropriate error messages
  void _showInvalidBillNumberError(int? billNumber) {
    final firstBillNumber = bills.first.billDetails.billNumber!;
    final lastBillNumber = bills.last.billDetails.billNumber!;

    final message = billNumber == null
        ? 'من فضلك أدخل رقم صحيح'
        : billNumber < firstBillNumber
            ? 'رقم الفاتورة غير متوفر. رقم أول فاتورة هو $firstBillNumber'
            : 'رقم الفاتورة غير متوفر. رقم أخر فاتورة هو $lastBillNumber';

    _displayErrorMessage(message);
  }

  /// Navigates to the bill by its number
  void goToBillByNumber(int? billNumber) {
    if (!_isValidBillNumber(billNumber)) {
      _showInvalidBillNumberError(billNumber);
      return;
    }

    final billIndex = _getBillIndexByNumber(billNumber);

    if (billIndex != -1) {
      _setCurrentBill(billIndex);
    } else {
      _displayErrorMessage('الفاتورة غير موجودة');
    }
  }

  /// Moves to the current bill if possible
  void reloadCurrentBill() {
    log('Navigating to current bill, current index: $currentBillIndex');
    if (currentBillIndex <= bills.length - 1) {
      _setCurrentBill(currentBillIndex);
    } else {
      _displayErrorMessage('لا يوجد فاتورة أخرى');
    }
  }

  /// Moves to the next bill if possible
  void next() {
    log('Navigating to next bill, current index: $currentBillIndex');
    if (currentBillIndex < bills.length - 1) {
      _setCurrentBill(currentBillIndex + 1);
    } else {
      _displayErrorMessage('لا يوجد فاتورة أخرى');
    }
  }

  /// Moves to the previous bill if possible
  void previous() {
    log('Navigating to previous bill, current index: $currentBillIndex');
    if (currentBillIndex > 0) {
      _setCurrentBill(currentBillIndex - 1);
    } else {
      _displayErrorMessage('لا يوجد فاتورة سابقة');
    }
  }

  /// Moves to the last bill in the list
  void last() {
    if (bills.isEmpty) {
      _displayErrorMessage('لا توجد فواتير متوفرة');
      return;
    }
    _setCurrentBill(bills.length - 1);
  }

  /// Updates the current bill and refreshes the screen`
  void _setCurrentBill(int index) {
    currentBillIndex = index;
    currentBill = bills[index];
    _updateBillDetailsOnScreen();
    update();
  }

  /// Refreshes the screen with the current bill's details
  void _updateBillDetailsOnScreen() {
    billDetailsController.updateBillDetailsOnScreen(
      currentBill,
      billDetailsPlutoController,
    );
  }

  /// Checks if the current bill is the last in the list
  bool get isLast => currentBillIndex == bills.length - 1;

  bool get isNew => currentBill.billId == null;

  bool get isPending => currentBill.status == Status.pending;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);
}
