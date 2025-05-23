import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/bill/data/models/bill_items.dart';
import '../../features/materials/data/models/materials/material_model.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import 'i_recodes_pluto_controller.dart';

abstract class IPlutoController<T> extends IRecodesPlutoController<T> {
  /// State manager for additions and discounts.
  PlutoGridStateManager get additionsDiscountsStateManager;

  /// Calculates the amount from a given ratio and total.
  String calculateAmountFromRatio(double ratio, double total);

  /// Calculates the ratio from a given amount and total.
  String calculateRatioFromAmount(double amount, double total);

  /// Computes the total including VAT.
  double get computeWithVatTotal;

  /// Computes the total excluding VAT.
  double get computeBeforeVatTotal;

  /// Computes the total VAT amount.
  double get computeTotalVat;

  /// Computes the total number of gift items.
  int get computeGiftsTotal;

  /// Computes the total value of gifts.
  double get computeGifts;

  /// Computes the total additions.
  double get computeAdditions;

  /// Computes the total discounts.
  double get computeDiscounts;

  /// Calculates the final total after applying discounts and additions.
  double get calculateFinalTotal;

  void moveToNextRow(PlutoGridStateManager stateManager, String cellField);

  void restoreCurrentCell(PlutoGridStateManager stateManager);

  Map<MaterialModel, List<TextEditingController>> get buyMaterialsSerialsControllers => {};

  Map<MaterialModel, List<TextEditingController>> get sellMaterialsSerialsControllers => {};

  void initSerialControllers(MaterialModel materialModel, int serialCount, BillItem billItem);

  /// this for mobile
  void updateWithSelectedMaterial({
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
    required MaterialModel? materialModel,
    required BillTypeModel billTypeModel,
  });
}