import '../enums/enums.dart';

extension BillPatternTypeExtension on BillPatternType {
  /// Returns whether the current [BillPatternType] has material account.
  bool get hasMaterialAccount {
    switch (this) {
      case BillPatternType.purchase:
      case BillPatternType.sales:
      case BillPatternType.buyReturn:
      case BillPatternType.salesReturn:
      case BillPatternType.add:
      case BillPatternType.remove:
        return true;
      default:
        return false;
    }
  }

  bool get hasVat {
    switch (this) {
      case BillPatternType.purchase:
      case BillPatternType.sales:
      case BillPatternType.buyReturn:
      case BillPatternType.salesReturn:
        return true;
      default:
        return false;
    }
  }

  /// Returns whether the current [BillPatternType] has cashes account.
  bool get hasCashesAccount {
    switch (this) {
      case BillPatternType.purchase:
      case BillPatternType.sales:
      case BillPatternType.buyReturn:
      case BillPatternType.salesReturn:
      case BillPatternType.add:
      case BillPatternType.remove:
        return true;
      default:
        return false;
    }
  }

  /// Returns whether the current [BillPatternType] has additions account.
  bool get hasAdditionsAccount {
    switch (this) {
      case BillPatternType.purchase:
      case BillPatternType.sales:
        return true;
      default:
        return false;
    }
  }

  /// Returns whether the current [BillPatternType] has discounts account.
  bool get hasDiscountsAccount {
    switch (this) {
      case BillPatternType.purchase:
      case BillPatternType.sales:
        return true;
      default:
        return false;
    }
  }

  /// Returns whether the current [BillPatternType] has gifts account.
  bool get hasGiftsAccount {
    switch (this) {
      case BillPatternType.purchase:
      case BillPatternType.sales:
        return true;
      default:
        return false;
    }
  }
}
