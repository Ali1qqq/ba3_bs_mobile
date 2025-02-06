import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../materials/data/models/materials/material_model.dart';

class BillPlutoUtils {
  final IPlutoController controller;

  BillPlutoUtils(this.controller);

  PlutoGridStateManager get additionsDiscountsStateManager => controller.additionsDiscountsStateManager;

  double getPrice({required MaterialModel materialModel, required PriceType type}) {
    switch (type) {
      case PriceType.consumer:
        return double.tryParse(materialModel.endUserPrice ?? '') ?? 0;
      case PriceType.bulk:
        return double.tryParse(materialModel.wholesalePrice ?? '') ?? 0;
      case PriceType.retail:
        return double.tryParse(materialModel.retailPrice ?? '') ?? 0;
    }
  }

  double parseExpression(String expression) {
    if (expression.isEmpty) return 0;
    return Parser().parse(expression).evaluate(EvaluationType.REAL, ContextModel());
  }

  bool isValidItemQuantity(PlutoRow row, String cellKey) {
    final String cellValue = row.cells[cellKey]?.value.toString() ?? '';

    int invRecQuantity = AppServiceUtils.replaceArabicNumbersWithEnglish(cellValue).toInt;

    return invRecQuantity > 0;
  }

  double getCellValueInDouble(Map<String, PlutoCell> cells, String cellKey) {
    final String cellValue = cells[cellKey]?.value.toString() ?? '';

    final cellValueStr = AppServiceUtils.replaceArabicNumbersWithEnglish(cellValue);

    return parseExpression(cellValueStr);
  }

  List<PlutoRow> emptyAdditionsDiscountsRecords() {
    return [
      PlutoRow(
        cells: {
          AppConstants.id: PlutoCell(value: AppConstants.accountName),
          AppConstants.discount: PlutoCell(value: ''),
          AppConstants.discountRatio: PlutoCell(value: ''),
          AppConstants.addition: PlutoCell(value: ''),
          AppConstants.additionRatio: PlutoCell(value: ''),
        },
      ),
      PlutoRow(
        cells: {
          AppConstants.id: PlutoCell(value: AppConstants.accountName),
          AppConstants.discount: PlutoCell(value: ''),
          AppConstants.discountRatio: PlutoCell(value: ''),
          AppConstants.addition: PlutoCell(value: ''),
          AppConstants.additionRatio: PlutoCell(value: ''),
        },
      )
    ];
  }
}
