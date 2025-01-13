import 'package:ba3_bs_mobile/features/main_layout/controllers/main_layout_controller.dart';
import 'package:ba3_bs_mobile/features/main_layout/ui/widgets/right_main_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../changes/controller/changes_controller.dart';
import '../../../changes/data/model/changes_model.dart';
import '../widgets/left_main_widget.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    put(MainLayoutController());
    put(ChangesController(read<ListenDataSourceRepository<ChangesModel>>()), permanent: true);

    return SafeArea(
      child: GetBuilder<MainLayoutController>(builder: (mainController) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(mainController.appLayouts[mainController.tabIndex].name,
                  style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor)),
              centerTitle: true,
            ),
            drawer: RightMainWidget(mainController: mainController),
            backgroundColor: AppColors.backGroundColor,
            body: LeftMainWidget(mainController: mainController),
          ),
        );
      }),
    );
  }
}
