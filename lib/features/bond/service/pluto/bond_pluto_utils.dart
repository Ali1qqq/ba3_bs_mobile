import 'package:math_expressions/math_expressions.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/utils/app_service_utils.dart';

class BondPlutoUtils {
  final IPlutoController controller;

  BondPlutoUtils(this.controller);

  double parseExpression(String expression) {
    if (expression.isEmpty) return 0;
    return Parser().parse(expression).evaluate(EvaluationType.REAL, ContextModel());
  }

  double getCellValueInDouble(Map<String, PlutoCell> cells, String cellKey) {
    final String cellValue = cells[cellKey]?.value.toString() ?? '';

    final cellValueStr = AppServiceUtils.replaceArabicNumbersWithEnglish(cellValue);

    return parseExpression(cellValueStr);
  }
}
