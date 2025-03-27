import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

PlutoGridStyleConfig buildGridStyleConfig({evenRowColor}) {
  return PlutoGridStyleConfig(
    rowHeight: 30,
    columnHeight: 30,
    evenRowColor: _getEvenRowColor(evenRowColor: evenRowColor),
    // columnTextStyle: _getColumnTextStyle(),
    activatedColor: _getActivatedColor(),
    // cellTextStyle: _getCellTextStyle(),
    gridPopupBorderRadius: _getBorderRadius(),
    gridBorderRadius: _getBorderRadius(),
  );
}

Color _getEvenRowColor({Color? evenRowColor}) {
  return evenRowColor!.withAlpha(204);
}

/*TextStyle _getColumnTextStyle() {
  return const TextStyle(
    // color: Colors.black,
    // fontSize: 12,
    fontFamily: 'Almarai',
    // fontWeight: FontWeight.bold,
  );
}*/

Color _getActivatedColor() {
  return Colors.white.withAlpha(127);
}

/*TextStyle _getCellTextStyle() {
  return const TextStyle(

    fontFamily: 'Almarai',
  );
}*/

BorderRadius _getBorderRadius() {
  return BorderRadius.circular(5);
}