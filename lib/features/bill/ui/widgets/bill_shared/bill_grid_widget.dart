import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/widgets/pluto_grid_style_config.dart';

class BillGridWidget extends StatelessWidget {
  final Color rowColor;
  final List<PlutoRow> rows;
  final List<PlutoColumn> columns;
  final Function(PlutoGridOnChangedEvent)? onChanged;
  final Function(PlutoGridOnLoadedEvent)? onLoaded;
  final PlutoGridShortcut? shortCut;

  const BillGridWidget({
    super.key,
    required this.rowColor,
    required this.rows,
    required this.columns,
    required this.onChanged,
    required this.onLoaded,
    this.shortCut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: PlutoGrid(
        onLoaded: onLoaded,
        configuration: PlutoGridConfiguration(
          shortcut: shortCut ?? const PlutoGridShortcut(),
          style: buildGridStyleConfig(evenRowColor: rowColor),
          localeText: const PlutoGridLocaleText.arabic(),
        ),
        columns: columns,
        rows: rows,
        onChanged: onChanged,
      ),
    );
  }
}
