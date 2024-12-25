import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../controller/print_controller.dart';

class PrintingLoadingDialog extends StatelessWidget {
  const PrintingLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() {
          // Observe dots and update text dynamically
          final dots = read<PrintingController>().loadingDots.value;
          return Text(
            'جاري الطباعه$dots',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          );
        }),
      ],
    );
  }
}
