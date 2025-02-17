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
  Future<void> initialize({
    required int lastBillNumber,
    required BillModel initialBill,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
  }) async {
    bills = await _prepareBillList(lastBillNumber, initialBill);
    currentBillIndex = _getBillIndexByNumber(initialBill.billDetails.billNumber);
    currentBill = bills[currentBillIndex];

    this.billDetailsController = billDetailsController;
    this.billDetailsPlutoController = billDetailsPlutoController;

    _setCurrentBill(currentBillIndex);
  }

  /// Prepares a list of bills with placeholders up to the last bill number.
  Future<List<BillModel>> _prepareBillList(int lastBillNumber, BillModel currentBill) async {
    // Create a growable list of placeholder bills
    final placeholders = List<BillModel>.generate(
      lastBillNumber - 1,
      (index) => _createPlaceholderBill(currentBill),
    );

    final currentBillNumber = currentBill.billDetails.billNumber!;

    // If the current bill is the last one, fetch the last bill from the database
    BillModel? lastBillOnDataBase;

    if (currentBillNumber == lastBillNumber && lastBillNumber > 1) {
      lastBillOnDataBase = await fetchLastBillOnDataBase(lastBillNumber - 1, currentBill);
    }

    if (lastBillOnDataBase != null) {
      // Replace the last placeholder with lastBillOnDataBase
      final updatedLastBillOnDataBase = lastBillOnDataBase.copyWith(
        billDetails: lastBillOnDataBase.billDetails.copyWith(
          next: lastBillOnDataBase.billDetails.billNumber! + 1,
        ),
      );

      placeholders[lastBillNumber - 2] = updatedLastBillOnDataBase;
    }

    // If the current bill is the last one, append it; otherwise, insert at the correct position
    if (currentBillNumber == lastBillNumber) {
      return [...placeholders, currentBill];
    } else {
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

  Future<BillModel?> fetchLastBillOnDataBase(int billNumber, BillModel currentBill) async {
    BillModel? fetchedBill;

    final result = await read<AllBillsController>().fetchBillByNumber(
      billTypeModel: currentBill.billTypeModel,
      billNumber: billNumber,
    );

    result.fold(
      (failure) {},
      (fetchedBills) => fetchedBill = fetchedBills.first,
    );

    return fetchedBill;
  }

  /// Retrieves the index of a bill by its number.
  int _getBillIndexByNumber(int? billNumber) => bills.indexWhere((bill) => bill.billDetails.billNumber == billNumber);

  /// Updates a bill if it exists.
  void updateBill(BillModel updatedBill, String from) {
    log(' updatedBill.from $from');
    log(' updatedBill.billNumber ${updatedBill.billDetails.billNumber}');
    log(' updatedBill.previous ${updatedBill.billDetails.previous}');
    log(' updatedBill.next ${updatedBill.billDetails.next}');

    final billIndex = _getBillIndexByNumber(updatedBill.billDetails.billNumber);
    if (billIndex != -1) {
      log(' billIndex $billIndex');
      log(' currentBillIndex == billIndex ${currentBillIndex == billIndex}');

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

    if (isNotLastBill) {
      log('currentBillIndex < bills.length');

      _setCurrentBill(currentBillIndex);
    } else {
      log('currentBillIndex !< bills.length');
      log(' billToDelete.billDetails.previous ${billToDelete.billDetails.previous}');
      //  updateDeletedBillPrevious(billToDelete);

      billDetailsController.appendNewBill(
        billTypeModel: billToDelete.billTypeModel,
        lastBillNumber: billToDelete.billDetails.billNumber!,
        previousBillNumber: billToDelete.billDetails.previous,
      );
    }
  }

  bool get isNotLastBill => currentBillIndex < bills.length;

  /// Validates the bill number range.
  bool _isValidBillNumber(int? billNumber) => billNumber != null && billNumber >= 1 && billNumber <= bills.last.billDetails.billNumber!;

  /// Navigates to a bill by its number.
  Future<void> goToBillByNumber(int? billNumber) async => await _navigateToBill(billNumber!, NavigationDirection.specific);

  /// Moves to the next bill if possible.
  Future<void> next() async =>
      await _navigateToBill(currentBill.billDetails.next ?? currentBill.billDetails.billNumber! + 1, NavigationDirection.next);

  /// Moves to the previous bill if possible.
  Future<void> previous() async =>
      await _navigateToBill(currentBill.billDetails.previous ?? currentBill.billDetails.billNumber! - 1, NavigationDirection.previous);

  /// Jumps forward by 10 bills from the current bill number.
  Future<void> jumpForwardByTen() async => await _navigateToBill(currentBill.billDetails.billNumber! + 10, NavigationDirection.next);

  /// Jumps backward by 10 bills from the current bill number.
  Future<void> jumpBackwardByTen() async => await _navigateToBill(currentBill.billDetails.billNumber! - 10, NavigationDirection.previous);

  /// Navigates to the first bill in the list.
  Future<void> head() async => await _navigateToBill(1, NavigationDirection.next);

  /// Navigates to the last bill in the list.
  Future<void> tail() async => await _navigateToBill(bills.last.billDetails.billNumber!, NavigationDirection.previous);

  /// Helper method to fetch or navigate to a specific bill.
  Future<void> _navigateToBill(int billNumber, NavigationDirection direction) async {
    if (!_validateAndHandleBillNumber(billNumber)) return;

    if (_checkExistingBill(billNumber)) return;

    await _fetchAndNavigateToBill(billNumber, direction);
  }

  bool _validateAndHandleBillNumber(int billNumber) {
    if (!_isValidBillNumber(billNumber)) {
      _showInvalidBillNumberError(billNumber);
      return false;
    }
    return true;
  }

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
    log('_handleFetchSuccess');

    if (fetchedBills.isEmpty) {
      _displayErrorMessage('No bills returned from the fetch operation.');
      return;
    }

    final fetchedBill = fetchedBills.first;

    _updateBillInList(billNumber, fetchedBill);
  }

  /// Updates the bill at the specified index, handling 'isTail' logic.
  void _updateBillInList(int billNumber, BillModel fetchedBill) {
    final index = billNumber - 1;

    bills[index] = fetchedBill;

    _setCurrentBill(index);
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

  void insertLastAndUpdate(BillModel newBill) {
    _updatePreviousTail(newBill.billDetails.billNumber);
    _addNewBill(newBill);
  }

  /// Adds the new bill to the list and sets it as the current bill.
  void _addNewBill(BillModel newBill) {
    bills.add(newBill);
    _setCurrentBill(bills.length - 1);
  }

  /// Updates the 'next' field of the last bill in the list (if applicable).
  void _updatePreviousTail(int? newBillNumber) {
    if (bills.isEmpty) return;

    final tail = getTail;

    final updatedTail = tail.copyWith(
      billDetails: tail.billDetails.copyWith(next: newBillNumber),
    );

    _replaceLastBill(updatedTail);
  }

  /// Replaces the last bill in the list with an updated version.
  void _replaceLastBill(BillModel updatedBill) {
    bills[bills.length - 1] = updatedBill;
  }

  bool isLastValidBill(BillModel bill) {
    final int billIndex = _getBillIndexByNumber(bill.billDetails.billNumber);
    if (billIndex == -1) return false; // Bill not found

    // Check if any valid bill exists after this one
    for (int i = billIndex + 1; i < bills.length; i++) {
      if (hasValidId(bills[i])) return false;
    }

    return hasValidId(bill); // The current bill must also be valid
  }

  /// Checks if a bill has a valid (non-null, non-empty) ID
  bool hasValidId(BillModel bill) => bill.billId != null && bill.billId!.isNotEmpty;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);

  BillModel getBillByNumber(int billNumber) => bills[_getBillIndexByNumber(billNumber)];

  /// Gets the current bill
  BillModel get getCurrentBill => bills[currentBillIndex];

  /// Checks if the current bill is the last in the list
  bool get isTail => currentBillIndex == bills.length - 1;

  /// Checks if the current bill is the last in the list
  bool get isHead => currentBillIndex == 0;

  bool get isNew => currentBill.billId == null;

  bool get isCash => currentBill.billDetails.billPayType == InvPayType.cash.index;

  bool get isPending => currentBill.status == Status.pending;

  BillModel get getTail => bills[bills.length - 1];
}