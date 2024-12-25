import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/pattern_controller.dart';
import 'add_pattern_page.dart';

class AllPatternScreen extends StatelessWidget {
  const AllPatternScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatternController>(
        builder: (controller) => PlutoGridWithAppBar(
              title: "أنماط البيع",
              isLoading: controller.isLoading,
              tableSourceModels: controller.billsTypes,
              onLoaded: (e) {},
              onSelected: (p0) {
                Get.to(const AddPatternPage());
              },
            ));
  }
}
