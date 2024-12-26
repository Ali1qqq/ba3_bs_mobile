import 'dart:io';

import 'package:ba3_bs_mobile/features/main_layout/controllers/main_layout_controller.dart';
import 'package:ba3_bs_mobile/features/main_layout/ui/widgets/right_main_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/styling/app_colors.dart';
import '../../controllers/window_close_controller.dart';
import '../widgets/left_main_widget.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<MainLayoutController>(builder: (mainController) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(),
            drawer: RightMainWidget(mainController: mainController),
            //         drawer:    RightMainWidget(mainController: mainController),

            backgroundColor: AppColors.backGroundColor,
            body: LeftMainWidget(mainController: mainController),
          ),
        );
      }),
    );
  }
}
