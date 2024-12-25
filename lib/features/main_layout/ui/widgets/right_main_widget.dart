import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../controllers/main_layout_controller.dart';
import 'drawer_list_tile.dart';
import 'main_header.dart';

class RightMainWidget extends StatelessWidget {
  const RightMainWidget({super.key, required this.mainController});

  final MainLayoutController mainController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        spacing: 10,
        children: [
          SizedBox(
            height: 0.15.sh,
            width: 0.14.sw,
            child: Image.asset(AppAssets.logo),
          ),
          SizedBox(
            height:(Platform.isWindows || Platform.isMacOS)? 0.725.sh:0.610.sh,
            width: 0.15.sw,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: mainController.appLayouts.length,
              separatorBuilder: (context, index) => const VerticalSpace(),
              itemBuilder: (context, index) => DrawerListTile(
                index: index,
                tabIndex: mainController.tabIndex,
                title: mainController.appLayouts[index].name,
                icon: mainController.appLayouts[index].icon,
                unSelectedIcon: mainController.appLayouts[index].unSelectedIcon,
                onTap: () {
                  mainController.setIndex = index;
                },
              ),
            ),
          ),
          const MainHeader(),
        ],
      ),
    );
  }
}
