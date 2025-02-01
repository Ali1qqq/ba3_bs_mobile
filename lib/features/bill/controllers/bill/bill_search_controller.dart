import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bill_details.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/bill_model.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillSearchController extends GetxController {
  late List<BillModel> bills;
  late BillModel currentBill;
  late int currentBillIndex;

  late BillDetailsController billDetailsController;
  late BillDetailsPlutoController billDetailsPlutoController;

  /// Initializes the bill search with the given bills and controllers.
  void initialize({
    required int lastBillNumber,
    required BillModel currentBill,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
  }) {
    bills = _prepareBillList(lastBillNumber, currentBill);
    currentBillIndex = _getBillIndexByNumber(currentBill.billDetails.billNumber);
    currentBill = bills[currentBillIndex];

    this.billDetailsController = billDetailsController;
    this.billDetailsPlutoController = billDetailsPlutoController;

    _setCurrentBill(currentBillIndex);
  }

  /// Prepares a list of bills with placeholders up to the last bill number.
  List<BillModel> _prepareBillList(int lastBillNumber, BillModel currentBill) {
    // Create a growable list of placeholder bills
    final placeholders = List<BillModel>.generate(
      lastBillNumber - 1,
      (index) => _createPlaceholderBill(currentBill),
    );

    final currentBillNumber = currentBill.billDetails.billNumber!;

    // If the current bill is the last one, append it to the list
    if (currentBillNumber == lastBillNumber) {
      return [...placeholders, currentBill];
    } else {
      // Otherwise, insert the current bill at the correct position
      return placeholders..insert(currentBillNumber - 1, currentBill);
    }
  }

  /// Creates a placeholder bill for missing entries.
  BillModel _createPlaceholderBill(BillModel referenceBill) => BillModel(
        billTypeModel: referenceBill.billTypeModel,
        status: Status.pending,
        items: const BillItems(itemList: []),
        billDetails: BillDetails(
          billPayType: InvPayType.cash.index,
          billDate: DateTime.now(),
        ),
      );

  /// Validates the bill number range.
  bool _isValidBillNumber(int? billNumber) => billNumber != null && billNumber >= 1 && billNumber <= bills.last.billDetails.billNumber!;

  /// Displays an error message for invalid bill numbers.
  void _showInvalidBillNumberError(int? billNumber) {
    final firstBillNumber = bills.first.billDetails.billNumber ?? 1;
    final lastBillNumber = bills.last.billDetails.billNumber!;
    final message = billNumber == null
        ? 'من فضلك أدخل رقم صحيح'
        : billNumber < firstBillNumber
            ? 'رقم الفاتورة غير متوفر. رقم أول فاتورة هو $firstBillNumber'
            : 'رقم الفاتورة غير متوفر. رقم أخر فاتورة هو $lastBillNumber';
    _displayErrorMessage(message);
  }

  /// Retrieves the index of a bill by its number.
  int _getBillIndexByNumber(int? billNumber) => bills.indexWhere((bill) => bill.billDetails.billNumber == billNumber);

  /// Updates a bill if it exists.
  void updateBill(BillModel updatedBill) {
    final billIndex = _getBillIndexByNumber(updatedBill.billDetails.billNumber);
    if (billIndex != -1) {
      bills[billIndex] = updatedBill;
      if (currentBillIndex == billIndex) currentBill = updatedBill;
      update();
    }
  }

  /// Removes a bill and reloads the current bill.
  void removeBill(BillModel billToDelete) {
    final billIndex = _getBillIndexByNumber(billToDelete.billDetails.billNumber);
    if (billIndex != -1) {
      bills.removeAt(billIndex);
      reloadCurrentBill(billToDelete: billToDelete);
    }
  }

  /// Reloads the current bill or shows an error if unavailable.
  void reloadCurrentBill({required BillModel billToDelete}) {
    log('currentBillIndex $currentBillIndex');
    log('bills.length ${bills.length}');
    if (currentBillIndex < bills.length) {
      log('currentBillIndex < bills.length');

      _setCurrentBill(currentBillIndex);
    } else {
      log('_displayErrorMessage');
      billDetailsController.appendNewBill(
        billTypeModel: billToDelete.billTypeModel,
        lastBillNumber: billToDelete.billDetails.billNumber!,
      );

      //   _displayErrorMessage('لا يوجد فاتورة أخرى');
    }
  }

  /// Navigates to a bill by its number.
  Future<void> goToBillByNumber(int? billNumber) async => await _navigateToBill(billNumber!, NavigationDirection.specific);

  /// Moves to the next bill if possible.
  Future<void> next() async => await _navigateToBill(currentBill.billDetails.billNumber! + 1, NavigationDirection.next);

  /// Moves to the previous bill if possible.
  Future<void> previous() async => await _navigateToBill(currentBill.billDetails.billNumber! - 1, NavigationDirection.previous);

  /// Jumps forward by 10 bills from the current bill number.
  Future<void> jumpForwardByTen() async => await _navigateToBill(currentBill.billDetails.billNumber! + 10, NavigationDirection.next);

  /// Jumps backward by 10 bills from the current bill number.
  Future<void> jumpBackwardByTen() async => await _navigateToBill(currentBill.billDetails.billNumber! - 10, NavigationDirection.previous);

  /// Navigates to the first bill in the list.
  Future<void> first() async => await _navigateToBill(1, NavigationDirection.next);

  /// Navigates to the last bill in the list.
  Future<void> last() async => await _navigateToBill(bills.last.billDetails.billNumber!, NavigationDirection.previous);

  /// Helper method to fetch or navigate to a specific bill.
  Future<void> _navigateToBill(int billNumber, NavigationDirection direction) async {
    if (!_validateAndHandleBillNumber(billNumber)) return;

    if (_checkExistingBill(billNumber)) return;

    await _fetchAndNavigateToBill(billNumber, direction);
  }

  bool _validateAndHandleBillNumber(int billNumber) {
    log('billNumber: ${billNumber}');
    log('bills.last.billDetails.billNumber: ${bills.last.billDetails.billNumber}');
    if (!_isValidBillNumber(billNumber)) {
      _showInvalidBillNumberError(billNumber);
      return false;
    }
    return true;
  }

  bool _checkExistingBill(int billNumber) {
    final existingBill = _findExistingBill(billNumber);
    if (existingBill != null) {
      log('Bill with number $billNumber already exists in the list.');
      _setCurrentBill(bills.indexOf(existingBill));
      return true;
    }
    return false;
  }

  /// Checks if the bill number exists in the list and returns its index, or null if not found.
  BillModel? _findExistingBill(int billNumber) => bills.firstWhereOrNull((bill) => bill.billDetails.billNumber == billNumber);

  /// Fetches the bill by number and handles success or failure.
  Future<void> _fetchAndNavigateToBill(int billNumber, NavigationDirection direction) async {
    final result = await read<AllBillsController>().fetchBillByNumber(
      billTypeModel: currentBill.billTypeModel,
      billNumber: billNumber,
    );

    result.fold(
      (failure) => _handleFetchFailure(failure, billNumber, direction),
      (fetchedBills) => _handleFetchSuccess(fetchedBills, billNumber),
    );
  }

  /// Handles a failed bill fetch and triggers navigation for adjacent bills if necessary.
  void _handleFetchFailure(Failure failure, int billNumber, NavigationDirection direction) {
    log('Fetching bill from source: $direction');

    if (direction == NavigationDirection.next) {
      _navigateToBill(billNumber + 1, direction);
    } else if (direction == NavigationDirection.previous) {
      _navigateToBill(billNumber - 1, direction);
    } else {
      _displayErrorMessage('لا يوجد فاتورة ${failure.message}');
    }
  }

  /// Handles a successful bill fetch and updates the list.
  void _handleFetchSuccess(List<BillModel> fetchedBills, int billNumber) {
    if (fetchedBills.isEmpty) {
      _displayErrorMessage('No bills returned from the fetch operation.');
      return;
    }

    bills[billNumber - 1] = fetchedBills.first;
    _setCurrentBill(billNumber - 1);
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

  /// Gets the current bill
  BillModel get getCurrentBill => bills[currentBillIndex];

  /// Checks if the current bill is the last in the list
  bool get isLast => currentBillIndex == bills.length - 1;

  /// Checks if the current bill is the last in the list
  bool get isFirst => currentBillIndex == 0;

  bool get isNew => currentBill.billId == null;

  bool get isCash => currentBill.billDetails.billPayType == InvPayType.cash.index;

  bool get isPending => currentBill.status == Status.pending;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);

  insertLastAndUpdate(BillModel newBill) {
    bills.add(newBill);
    _setCurrentBill(bills.indexOf(newBill));
  }
}
