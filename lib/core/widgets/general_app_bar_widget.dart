import 'package:ba3_bs_mobile/features/main_layout/controllers/main_layout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

AppBar generalAppBar() {
  return AppBar(

    leading:    IconButton(
        onPressed: () {
          Get.find<MainLayoutController>().openDrawer();
        },
        icon: Icon(Icons.menu)),
    actions: [

    ],
  );
}
