
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

// Function to create a numbered column with automatic ID generation.
PlutoColumn createAutoIdColumn({String title = '', double width = 50}) => PlutoColumn(
      width: width,
      title: title,
      field: title,
      frozen: PlutoColumnFrozen.start,
      enableContextMenu: false,
      enableDropToResize: false,
      // Assuming field name matches the title.
      type: PlutoColumnType.number(),
      renderer: (rendererContext) {
        final currentPage = rendererContext.stateManager.page;
        final rowIndex = rendererContext.rowIdx;
        final autoId = calculateAutoId(currentPage, rowIndex);



        return Text(
          autoId.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        );
      },
    );

int calculateAutoId(int currentPage, int rowIndex) => (currentPage - 1) * 100 + rowIndex + 1;
