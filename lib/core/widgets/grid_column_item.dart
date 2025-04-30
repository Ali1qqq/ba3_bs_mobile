import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

GridColumn gridColumnItem(
    {required String label,
    required String name,
    Color? color,
    double fontSize = 20}) {
  return GridColumn(
      allowEditing: false,
      columnName: name,
      label: Container(
          color: color ?? Colors.blue.shade800,
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize),
          )));
}
