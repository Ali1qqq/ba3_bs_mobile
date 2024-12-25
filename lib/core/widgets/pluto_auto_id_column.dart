import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';


// This is for generating an automatic numbered column.
PlutoColumn plutoAutoIdColumn() {
  return PlutoColumn(
    width: 50,
    title: '',
    field: 'رقم السطر',
    type: PlutoColumnType.number(),
    renderer: (rendererContext) {
      return Text(
        (rendererContext.rowIdx + 1).toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    },
  );
}