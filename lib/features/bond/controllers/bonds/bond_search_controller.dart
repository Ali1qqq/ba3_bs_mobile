import 'dart:developer';

import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/pay_item_model.dart';
import '../pluto/bond_details_pluto_controller.dart';

class BondSearchController extends GetxController {
  late List<BondModel> bonds;
  late BondModel currentBond;
  late int currentBondIndex;

  late BondDetailsController bondDetailsController;
  late BondDetailsPlutoController bondDetailsPlutoController;

  /// Initializes the Bond search with the given bonds and controllers.
  void initialize({
    required List<BondModel> allBonds,
    required BondModel newBond,
    required BondDetailsController bondDetailsController,
    required BondDetailsPlutoController bondDetailsPlutoController,
  }) {
    bonds = _prepareBondList(allBonds, newBond);
    currentBondIndex = _getBondIndexByNumber(newBond.payNumber);
    currentBond = bonds[currentBondIndex];
    this.bondDetailsController = bondDetailsController;
    this.bondDetailsPlutoController = bondDetailsPlutoController;

    _setCurrentBond(currentBondIndex);
  }

  /// Prepares a list of bonds with placeholders up to the last Bond number.
  List<BondModel> _prepareBondList(List<BondModel> allBonds, BondModel currentBond) {
    final placeholders = List<BondModel>.filled(
      allBonds.last.payNumber! - 1,
      _createPlaceholderBond(currentBond),
    );
    return [...placeholders, currentBond];
  }

  /// Creates a placeholder Bond for missing entries.bond
  BondModel _createPlaceholderBond(BondModel referenceBond) {
    return BondModel(
        payAccountGuid: '',
        payItems: PayItems(itemList: []),
        payTypeGuid: referenceBond.payTypeGuid,
        payDate: DateTime.now().toIso8601String());
  }

  /// Validates the Bond number range.
  bool _isValidBondNumber(int? bondNumber) {
    return bondNumber != null && bondNumber >= 1 && bondNumber <= bonds.last.payNumber!;
  }

  /// Displays an error message for invalid Bond numbers.
  void _showInvalidBondNumberError(int? bondNumber) {
    final firstBondNumber = bonds.first.payNumber ?? 1;
    final lastBondNumber = bonds.last.payNumber!;
    final message = bondNumber == null
        ? 'من فضلك أدخل رقم صحيح'
        : bondNumber < firstBondNumber
            ? 'رقم الفاتورة غير متوفر. رقم أول فاتورة هو $firstBondNumber'
            : 'رقم الفاتورة غير متوفر. رقم أخر فاتورة هو $lastBondNumber';
    _displayErrorMessage(message);
  }

  /// Retrieves the index of a Bond by its number.
  int _getBondIndexByNumber(int? bondNumber) {
    return bonds.indexWhere((bond) => bond.payNumber == bondNumber);
  }

  /// Updates a Bond if it exists.
  void updateBond(BondModel updatedBond) {
    final bondIndex = _getBondIndexByNumber(updatedBond.payNumber);
    if (bondIndex != -1) {
      bonds[bondIndex] = updatedBond;
      if (currentBondIndex == bondIndex) currentBond = updatedBond;
      update();
    }
  }

  /// Removes a Bond and reloads the current Bond.
  void removeBond(BondModel bondToDelete) {
    final bondIndex = _getBondIndexByNumber(bondToDelete.payNumber);
    if (bondIndex != -1) {
      bonds.removeAt(bondIndex);
      reloadCurrentBond();
    }
  }

  /// Reloads the current Bond or shows an error if unavailable.
  void reloadCurrentBond() {
    if (currentBondIndex < bonds.length) {
      _setCurrentBond(currentBondIndex);
    } else {
      _displayErrorMessage('لا يوجد فاتورة أخرى');
    }
  }

  /// Navigates to a Bond by its number.
  Future<void> goToBondByNumber(int? bondNumber) async => await _navigateToBond(bondNumber!, NavigationDirection.specific);

  /// Moves to the next Bond if possible.
  Future<void> next() async => await _navigateToBond(currentBond.payNumber! + 1, NavigationDirection.next);

  /// Moves to the previous Bond if possible.
  Future<void> previous() async => await _navigateToBond(currentBond.payNumber! - 1, NavigationDirection.previous);

  /// Moves to the next Bond if possible.
  Future<void> jumpTenForward() async => await _navigateToBond(currentBond.payNumber! + 10, NavigationDirection.next);

  /// Moves to the previous Bond if possible.
  Future<void> jumpTenBackward() async => await _navigateToBond(currentBond.payNumber! - 10, NavigationDirection.previous);

  /// Moves to the next Bond if possible.
  Future<void> first() async => await _navigateToBond(1, NavigationDirection.next);

  /// Moves to the previous Bond if possible.
  Future<void> last() async => await _navigateToBond(bonds.last.payNumber!, NavigationDirection.previous);

  /// Helper method to fetch or navigate to a specific Bond.
  Future<void> _navigateToBond(int bondNumber, NavigationDirection source) async {
    if (!_validateAndHandleBondNumber(bondNumber)) return;

    if (_checkExistingBond(bondNumber)) return;

    await _fetchAndNavigateToBond(bondNumber, source);
  }

  bool _validateAndHandleBondNumber(int bondNumber) {
    if (!_isValidBondNumber(bondNumber)) {
      _showInvalidBondNumberError(bondNumber);
      return false;
    }
    return true;
  }

  bool _checkExistingBond(int bondNumber) {
    final existingBond = _findExistingBond(bondNumber);
    if (existingBond != null) {
      log('Bond with number $bondNumber already exists in the list.');
      _setCurrentBond(bonds.indexOf(existingBond));
      return true;
    }
    return false;
  }

  /// Checks if the Bond number exists in the list and returns its index, or null if not found.
  BondModel? _findExistingBond(int bondNumber) => bonds.firstWhereOrNull((bond) => bond.payNumber == bondNumber);

  /// Fetches the Bond by number and handles success or failure.
  Future<void> _fetchAndNavigateToBond(int bondNumber, NavigationDirection source) async {
    final result = await read<AllBondsController>().fetchBondByNumber(
      bondType: BondType.byTypeGuide(currentBond.payTypeGuid!),
      bondNumber: bondNumber,
    );

    result.fold(
      (failure) => _handleFetchFailure(failure, bondNumber, source),
      (fetchedBonds) => _handleFetchSuccess(fetchedBonds, bondNumber),
    );
  }

  /// Handles a failed Bond fetch and triggers navigation for adjacent bonds if necessary.
  void _handleFetchFailure(Failure failure, int bondNumber, NavigationDirection source) {
    log('Fetching Bond from source: $source');

    if (source == NavigationDirection.next) {
      _navigateToBond(bondNumber + 1, source);
    } else if (source == NavigationDirection.previous) {
      _navigateToBond(bondNumber - 1, source);
    } else {
      _displayErrorMessage('لا يوجد فاتورة ${failure.message}');
    }
  }

  /// Handles a successful Bond fetch and updates the list.
  void _handleFetchSuccess(List<BondModel> fetchedBonds, int bondNumber) {
    if (fetchedBonds.isEmpty) {
      _displayErrorMessage('No bonds returned from the fetch operation.');
      return;
    }

    bonds[bondNumber - 1] = fetchedBonds.first;
    _setCurrentBond(bondNumber - 1);
  }

  /// Updates the current Bond and refreshes the screen`
  void _setCurrentBond(int index) {
    currentBondIndex = index;
    currentBond = bonds[index];
    _updateBondDetailsOnScreen();
    update();
  }

  /// Refreshes the screen with the current Bond's details
  void _updateBondDetailsOnScreen() {
    bondDetailsController.updateBondDetailsOnScreen(
      currentBond,
      bondDetailsPlutoController,
    );
  }

  /// Gets the current Bond
  BondModel get getCurrentBond => bonds[currentBondIndex];

  /// Checks if the current Bond is the last in the list
  bool get isLast => currentBondIndex == bonds.length - 1;

  /// Checks if the current Bond is the last in the list
  bool get isFirst => currentBondIndex == 0;

  bool get isNew => currentBond.payGuid == null;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);
}
