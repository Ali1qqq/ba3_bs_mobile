import 'package:flutter/cupertino.dart' show LogicalKeySet;
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

PlutoGridShortcut customPlutoShortcut(PlutoGridShortcutAction plutoGridEnterAction) {
  return PlutoGridShortcut(
    actions: {
      ..._buildMoveCellFocusActions(),
      ..._buildMoveSelectedCellFocusActions(),
      ..._buildPageNavigationActions(),
      ..._buildTabKeyActions(),
      ..._buildEnterKeyActions(plutoGridEnterAction),
      ..._buildEscapeKeyActions(),
      ..._buildEdgeNavigationActions(),
      ..._buildEditingActions(),
      ..._buildClipboardActions(),
      ..._buildMiscellaneousActions(),
    },
  );
}

// Move cell focus actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildMoveCellFocusActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PlutoGridActionMoveCellFocus(PlutoMoveDirection.right),
    LogicalKeySet(LogicalKeyboardKey.arrowRight): const PlutoGridActionMoveCellFocus(PlutoMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.arrowUp): const PlutoGridActionMoveCellFocus(PlutoMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.arrowDown): const PlutoGridActionMoveCellFocus(PlutoMoveDirection.down),
  };
}

// Move selected cell focus actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildMoveSelectedCellFocusActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowLeft):
        const PlutoGridActionMoveSelectedCellFocus(PlutoMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowRight):
        const PlutoGridActionMoveSelectedCellFocus(PlutoMoveDirection.right),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowUp):
        const PlutoGridActionMoveSelectedCellFocus(PlutoMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowDown):
        const PlutoGridActionMoveSelectedCellFocus(PlutoMoveDirection.down),
  };
}

// Page navigation actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildPageNavigationActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.pageUp): const PlutoGridActionMoveCellFocusByPage(PlutoMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.pageDown): const PlutoGridActionMoveCellFocusByPage(PlutoMoveDirection.down),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.pageUp):
        const PlutoGridActionMoveSelectedCellFocusByPage(PlutoMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.pageDown):
        const PlutoGridActionMoveSelectedCellFocusByPage(PlutoMoveDirection.down),
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.pageUp):
        const PlutoGridActionMoveCellFocusByPage(PlutoMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.pageDown):
        const PlutoGridActionMoveCellFocusByPage(PlutoMoveDirection.right),
  };
}

// Tab key actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildTabKeyActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.tab): const PlutoGridActionDefaultTab(),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
        const PlutoGridActionMoveCellFocusByPage(PlutoMoveDirection.right),
  };
}

// Enter key actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildEnterKeyActions(PlutoGridShortcutAction plutoGridEnterAction) {

  return {
    LogicalKeySet(LogicalKeyboardKey.enter): plutoGridEnterAction,
    LogicalKeySet(LogicalKeyboardKey.numpadEnter): plutoGridEnterAction,
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter): plutoGridEnterAction,
  };
}

// Escape key actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildEscapeKeyActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.escape): const PlutoGridActionDefaultEscapeKey(),
  };
}

// Edge navigation actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildEdgeNavigationActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.home): const PlutoGridActionMoveCellFocusToEdge(PlutoMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.end): const PlutoGridActionMoveCellFocusToEdge(PlutoMoveDirection.right),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.home):
        const PlutoGridActionMoveCellFocusToEdge(PlutoMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.end):
        const PlutoGridActionMoveCellFocusToEdge(PlutoMoveDirection.down),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.home):
        const PlutoGridActionMoveSelectedCellFocusToEdge(PlutoMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.end):
        const PlutoGridActionMoveSelectedCellFocusToEdge(PlutoMoveDirection.right),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.home):
        const PlutoGridActionMoveSelectedCellFocusToEdge(PlutoMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.end):
        const PlutoGridActionMoveSelectedCellFocusToEdge(PlutoMoveDirection.down),
  };
}

// Editing actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildEditingActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.f2): const PlutoGridActionSetEditing(),
    LogicalKeySet(LogicalKeyboardKey.f3): const PlutoGridActionFocusToColumnFilter(),
    LogicalKeySet(LogicalKeyboardKey.f4): const PlutoGridActionToggleColumnSort(),
  };
}

// Clipboard actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildClipboardActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC): const PlutoGridActionCopyValues(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV): const PlutoGridActionPasteValues(),
  };
}

// Miscellaneous actions
Map<LogicalKeySet, PlutoGridShortcutAction> _buildMiscellaneousActions() {
  return {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA): const PlutoGridActionSelectAll(),
  };
}
