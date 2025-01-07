import 'dart:developer';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../pluto/bond_details_pluto_controller.dart';

class BondSearchController extends GetxController {
  late List<BondModel> bonds;
  late BondModel currentBond;
  late int currentBondIndex;
  late BondDetailsController bondDetailsController;
  late BondDetailsPlutoController bondDetailsPlutoController;

  /// Initializes the bond search with the given bonds and current bond
  void initialize({
    required List<BondModel> bondsByCategory,
    required BondModel bond,
    required BondDetailsController bondDetailsController,
    required BondDetailsPlutoController bondDetailsPlutoController,
  }) {
    bonds = bondsByCategory;
    currentBondIndex = bonds.indexWhere(
      (current) => current.payGuid == bond.payGuid || current == bond,
    );
    currentBond = bonds[currentBondIndex];

    this.bondDetailsController = bondDetailsController;
    this.bondDetailsPlutoController = bondDetailsPlutoController;
    _setCurrentBond(currentBondIndex);
  }

  /// Gets the current bond
  BondModel get getCurrentBond => bonds[currentBondIndex];

  /// Finds the index of the bond with the given number
  int _getBondIndexByNumber(int? bondNumber) => bonds.indexWhere((bond) => bond.payNumber == bondNumber);

  /// Updates the bond in the search results if it exists
  void updateBond(BondModel updatedBond) {
    final bondIndex = _getBondIndexByNumber(updatedBond.payNumber);

    if (bondIndex != -1) {
      bonds[bondIndex] = updatedBond;
    }
    update();
  }

  /// Deletes the bond in the search results if it exists
  void removeBond(BondModel bondToDelete) {
    final bondIndex = _getBondIndexByNumber(bondToDelete.payNumber);

    if (bondIndex != -1) {
      bonds.removeAt(bondIndex);
      reloadCurrentBond();

      update();
    }
  }

  /// Validates whether the given bond number is within range
  bool _isValidBondNumber(int? bondNumber) =>
      bondNumber != null && bondNumber >= bonds.first.payNumber! && bondNumber <= bonds.last.payNumber!;

  /// Handles invalid bond number cases by showing appropriate error messages
  void _showInvalidBondNumberError(int? bondNumber) {
    final firstBondNumber = bonds.first.payNumber!;
    final lastBondNumber = bonds.last.payNumber!;

    final message = bondNumber == null
        ? 'من فضلك أدخل رقم صحيح'
        : bondNumber < firstBondNumber
            ? 'رقم السند غير متوفر. رقم أول سند هو $firstBondNumber'
            : 'رقم السند غير متوفر. رقم أخر سند هو $lastBondNumber';

    _displayErrorMessage(message);
  }

  /// Navigates to the bond by its number
  void goToBondByNumber(int? bondNumber) {
    if (!_isValidBondNumber(bondNumber)) {
      _showInvalidBondNumberError(bondNumber);
      return;
    }

    final bondIndex = _getBondIndexByNumber(bondNumber);

    if (bondIndex != -1) {
      _setCurrentBond(bondIndex);
    } else {
      _displayErrorMessage('السند غير موجودة');
    }
  }

  /// Moves to the current bond if possible
  void reloadCurrentBond() {
    log('Navigating to current bond, current index: $currentBondIndex');
    if (currentBondIndex <= bonds.length - 1) {
      _setCurrentBond(currentBondIndex);
    } else {
      _displayErrorMessage('لا يوجد سند أخر');
    }
  }

  /// Moves to the next bond if possible
  void next() {
    log('Navigating to next bond, current index: $currentBondIndex');
    if (currentBondIndex < bonds.length - 1) {
      _setCurrentBond(currentBondIndex + 1);
    } else {
      _displayErrorMessage('لا يوجد سند أخرى');
    }
  }

  /// Moves to the previous bond if possible
  void previous() {
    log('Navigating to previous bond, current index: $currentBondIndex');
    if (currentBondIndex > 0) {
      _setCurrentBond(currentBondIndex - 1);
    } else {
      _displayErrorMessage('لا يوجد سند سابقة');
    }
  }

  /// Moves to the last bond in the list
  void last() {
    if (bonds.isEmpty) {
      _displayErrorMessage('لا توجد فواتير متوفرة');
      return;
    }
    _setCurrentBond(bonds.length - 1);
  }

  /// Updates the current bond and refreshes the screen`
  void _setCurrentBond(int index) {
    currentBondIndex = index;
    currentBond = bonds[index];
    _updateBondDetailsOnScreen();
    update();
  }

  /// Refreshes the screen with the current bond's details
  void _updateBondDetailsOnScreen() {
    bondDetailsPlutoController.setAccountGuid = currentBond.payGuid ?? '';
    bondDetailsController.updateBondDetailsOnScreen(
      currentBond,
      bondDetailsPlutoController,
    );
  }

  /// Checks if the current bond is the last in the list
  bool get isLast => currentBondIndex == bonds.length - 1;

  bool get isNew => currentBond.payGuid == null;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);
}
