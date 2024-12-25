import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

PlutoGridStyleConfig buildGridStyleConfig({evenRowColor}) {
  return PlutoGridStyleConfig(
    evenRowColor: _getEvenRowColor(evenRowColor: evenRowColor),
    columnTextStyle: _getColumnTextStyle(),
    activatedColor: _getActivatedColor(),
    cellTextStyle: _getCellTextStyle(),
    gridPopupBorderRadius: _getBorderRadius(),
    gridBorderRadius: _getBorderRadius(),
  );
}

Color _getEvenRowColor({Color? evenRowColor}) {
  return evenRowColor!.withAlpha(204);
}

TextStyle _getColumnTextStyle() {
  return const TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}

Color _getActivatedColor() {
  return Colors.white.withAlpha(127);
}

TextStyle _getCellTextStyle() {
  return const TextStyle(
    color: Colors.black,
    fontSize: 14,
  );
}

BorderRadius _getBorderRadius() {
  return BorderRadius.circular(5);
}
