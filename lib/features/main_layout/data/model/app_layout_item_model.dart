import 'package:flutter/cupertino.dart';


  class   AppLayoutItemModel {
  final String name;
  final Widget layout;
  final String icon;
  final String unSelectedIcon;

  AppLayoutItemModel({
    required this.name,
    required this.layout,
    required this.icon,
    required this.unSelectedIcon,
  });
}