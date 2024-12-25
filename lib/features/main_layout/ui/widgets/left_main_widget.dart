import 'package:flutter/material.dart';

import '../../controllers/main_layout_controller.dart';

class LeftMainWidget extends StatelessWidget {
  const LeftMainWidget({super.key, required this.mainController});

  final MainLayoutController mainController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        onPageChanged: (value) {
          mainController.setIndex = value;
        },
        controller: mainController.pageController,
        itemCount: mainController.appLayouts.length,
        itemBuilder: (context, index) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                child: child,
              );
            },
            child: mainController.appLayouts[mainController.tabIndex].layout,
          );
        },
      ),
    );
  }
}
