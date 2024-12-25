import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/router/app_routes.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/entry_bond/entry_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../../bond/ui/screens/entry_bond_details_screen.dart';
import '../data/datasources/remote/accounts_statements_data_source.dart';

class AccountStatementController extends GetxController with FloatingLauncher, AppNavigator {
  // Dependencies
  final AccountsStatementsRepository _accountsStatementsRepo;
  final AccountsController _accountsController = read<AccountsController>();

  AccountStatementController(this._accountsStatementsRepo);

  // Text Controllers
  final productForSearchController = TextEditingController();
  final groupForSearchController = TextEditingController();
  final accountNameController = TextEditingController();
  final storeForSearchController = TextEditingController();
  final startDateController = TextEditingController()..text = _formattedToday;
  final endDateController = TextEditingController()..text = _formattedToday;

  // Data
  final List<EntryBondItemModel> entryBondItems = [];
  List<EntryBondItemModel> filteredEntryBondItems = [];

  // State variables
  bool isLoading = false;

  double totalValue = 0.0;
  double debitValue = 0.0;
  double creditValue = 0.0;

  @override
  void onInit() {
    super.onInit();
    resetFields();
  }

  /// Clears fields and resets state
  void resetFields({String? initialAccount}) {
    productForSearchController.clear();
    groupForSearchController.clear();
    storeForSearchController.clear();
    startDateController.text = _formattedToday;
    endDateController.text = _formattedToday;

    if (initialAccount != null) {
      accountNameController.text = initialAccount;
    } else {
      accountNameController.clear();
    }
  }

  // Event Handlers
  void onAccountNameSubmitted(String text, BuildContext context) {
    accountNameController.text = AppUIUtils.convertArabicNumbers(text);

    _accountsController.openAccountSelectionDialog(
      query: accountNameController.text,
      context: context,
      textEditingController: accountNameController,
    );
    update();
  }

  void onStartDateSubmitted(String text) {
    startDateController.text = AppUIUtils.getDateFromString(text);
    update();
  }

  void onEndDateSubmitted(String text) {
    endDateController.text = AppUIUtils.getDateFromString(text);
    update();
  }

  // Fetch bond items for the selected account
  Future<void> fetchAccountEntryBondItems() async {
    final accountModel = _accountsController.getAccountModelByName(accountNameController.text);
    if (accountModel == null) {
      _showErrorSnackBar("خطأ إدخال", "يرجى إدخال اسم الحساب");
      return;
    }

    isLoading = true;
    update();

    final result = await _accountsStatementsRepo.getAllBonds(accountModel.id!);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedItems) {
        entryBondItems.assignAll(fetchedItems);
        filterByDate();

        _calculateValues(filteredEntryBondItems);
      },
    );

    isLoading = false;
    update();
  }

  void filterByDate() {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy'); // Match your date format

    final DateTime startDate = dateFormat.parse(startDateController.text);
    final DateTime endDate = dateFormat.parse(endDateController.text);

    filteredEntryBondItems = entryBondItems.where((item) {
      final String? entryBondItemDateStr = item.date; // Ensure `date` is the correct field
      if (entryBondItemDateStr == null) return false;

      DateTime? entryBondItemDate;
      try {
        entryBondItemDate = dateFormat.parse(entryBondItemDateStr);
      } catch (e) {
        log('e $e ');
        return false; // Skip invalid date formats
      }

      return entryBondItemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entryBondItemDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Navigation handler
  void navigateToAccountStatementScreen() {
    to(AppRoutes.accountStatementScreen);
  }

  /// Calculates debit, credit, and total values
  void _calculateValues(List<EntryBondItemModel> items) {
    if (items.isEmpty) {
      _resetValues();
    } else {
      _updateValues(items);
    }
  }

  _resetValues() {
    totalValue = 0.0;
    debitValue = 0.0;
    creditValue = 0.0;
  }

  _updateValues(List<EntryBondItemModel> items) {
    debitValue = _calculateSum(items: items, type: BondItemType.debtor);
    creditValue = _calculateSum(items: items, type: BondItemType.creditor);

    totalValue = debitValue - creditValue;
  }

  double _calculateSum({required List<EntryBondItemModel> items, required BondItemType type}) => items.fold(
        0.0,
        (sum, item) => item.bondItemType == type ? sum + (item.amount ?? 0.0) : sum,
      );

  String get screenTitle =>
      'حركات ${accountNameController.text} من تاريخ ${startDateController.text} إلى تاريخ ${endDateController.text}';

  // Helper Methods
  static String get _formattedToday => DateTime.now().toString().split(" ")[0];

  void _showErrorSnackBar(String title, String message) {
    Get.snackbar(title, message, icon: const Icon(Icons.error_outline));
  }

  void launchBondEntryBondScreen({required BuildContext context, required String originId}) async {
    EntryBondModel entryBondModel = await read<EntryBondController>().getEntryBondById(entryId: originId);

    if (!context.mounted) return;
    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${entryBondModel.origin!.originType!.label}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }
}
