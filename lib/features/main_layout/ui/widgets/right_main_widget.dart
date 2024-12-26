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
    return Drawer(
      width: 250,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          spacing: 10,
          children: [
            Image.asset(
              AppAssets.logo,
              height: 150,
              width: 200,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 18),
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
      ),
    );
  }
}
