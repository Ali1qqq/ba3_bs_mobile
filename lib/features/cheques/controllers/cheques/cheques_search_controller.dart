import 'dart:developer';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_ui_utils.dart';

class ChequesSearchController extends GetxController {
  late List<ChequesModel> chequesList;
  late ChequesModel currentCheques;
  late int currentChequesIndex;
  late ChequesDetailsController chequesDetailsController;

  /// Initializes the cheques search with the given cheques and current cheques
  void initialize({
    required List<ChequesModel> chequesByCategory,
    required ChequesModel cheques,
    required ChequesDetailsController chequesDetailsController,
  }) {
    chequesList = chequesByCategory;
    currentChequesIndex = chequesList.indexWhere((current) =>current.chequesGuid==cheques.chequesGuid||current==cheques ,);
    currentCheques = chequesList[currentChequesIndex];
    this.chequesDetailsController = chequesDetailsController;
    _setCurrentCheques(currentChequesIndex);
    log('cheques length ${chequesList.length}');
    log('currentChequesIndex $currentChequesIndex');
    log('currentChequesNumber ${currentCheques.chequesNumber}');
  }

  /// Gets the current cheques
  ChequesModel get getCurrentCheques => chequesList[currentChequesIndex];

  /// Finds the index of the cheques with the given number
  int _getChequesIndexByNumber(int? chequesNumber) => chequesList.indexWhere((cheques) => cheques.chequesNumber == chequesNumber);

  /// Updates the cheques in the search results if it exists
  void updateCheques(ChequesModel updatedCheques) {
    final chequesIndex = _getChequesIndexByNumber(updatedCheques.chequesNumber);

    if (chequesIndex != -1) {
      chequesList[chequesIndex] = updatedCheques;
    }
    update();
  }

  /// Deletes the cheques in the search results if it exists
  void removeCheques(ChequesModel chequesToDelete) {
    final chequesIndex = _getChequesIndexByNumber(chequesToDelete.chequesNumber);

    if (chequesIndex != -1) {
      chequesList.removeAt(chequesIndex);
      reloadCurrentCheques();

      update();
    }
  }

  /// Validates whether the given cheques number is within range
  bool _isValidChequesNumber(int? chequesNumber) =>
      chequesNumber != null &&
      chequesNumber >= chequesList.first.chequesNumber! &&
      chequesNumber <= chequesList.last.chequesNumber!;

  /// Handles invalid cheques number cases by showing appropriate error messages
  void _showInvalidChequesNumberError(int? chequesNumber) {
    final firstChequesNumber = chequesList.first.chequesNumber!;
    final lastChequesNumber = chequesList.last.chequesNumber!;

    final message = chequesNumber == null
        ? 'من فضلك أدخل رقم صحيح'
        : chequesNumber < firstChequesNumber
            ? 'رقم السند غير متوفر. رقم أول سند هو $firstChequesNumber'
            : 'رقم السند غير متوفر. رقم أخر سند هو $lastChequesNumber';

    _displayErrorMessage(message);
  }

  /// Navigates to the cheques by its number
  void goToChequesByNumber(int? chequesNumber) {
    if (!_isValidChequesNumber(chequesNumber)) {
      _showInvalidChequesNumberError(chequesNumber);
      return;
    }

    final chequesIndex = _getChequesIndexByNumber(chequesNumber);

    if (chequesIndex != -1) {
      _setCurrentCheques(chequesIndex);
    } else {
      _displayErrorMessage('السند غير موجودة');
    }
  }

  /// Moves to the current cheques if possible
  void reloadCurrentCheques() {
    log('Navigating to current cheques, current index: $currentChequesIndex');
    if (currentChequesIndex <= chequesList.length - 1) {
      _setCurrentCheques(currentChequesIndex);
    } else {
      _displayErrorMessage('لا يوجد سند أخر');
    }
  }

  /// Moves to the next cheques if possible
  void next() {
    log('Navigating to next cheques, current index: $currentChequesIndex');
    if (currentChequesIndex < chequesList.length - 1) {
      _setCurrentCheques(currentChequesIndex + 1);
    } else {
      _displayErrorMessage('لا يوجد سند أخرى');
    }
  }

  /// Moves to the previous cheques if possible
  void previous() {
    log('Navigating to previous cheques, current index: $currentChequesIndex');
    if (currentChequesIndex > 0) {
      _setCurrentCheques(currentChequesIndex - 1);
    } else {
      _displayErrorMessage('لا يوجد سند سابقة');
    }
  }

  /// Moves to the last cheques in the list
  void last() {
    if (chequesList.isEmpty) {
      _displayErrorMessage('لا توجد فواتير متوفرة');
      return;
    }
    _setCurrentCheques(chequesList.length - 1);
  }

  /// Updates the current cheques and refreshes the screen`
  void _setCurrentCheques(int index) {
    currentChequesIndex = index;
    currentCheques = chequesList[index];
    _updateChequesDetailsOnScreen();
    update();
  }

  /// Refreshes the screen with the current cheques's details
  void _updateChequesDetailsOnScreen() {
    chequesDetailsController.updateChequesDetailsOnScreen(
      currentCheques,
    );
  }

  /// Checks if the current cheques is the last in the list
  bool get isLast => currentChequesIndex == chequesList.length - 1;

  bool get isNew => currentCheques.chequesGuid == null;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);
}
