import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../controllers/pattern_controller.dart';

class PatternTypeDropdown extends StatelessWidget {
  const PatternTypeDropdown({
    super.key,
    required this.patternController,
  });

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.45,
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('نوع الفاتورة')),
          Container(
              width: (Get.width * 0.45) - 100,
              height: AppConstants.constHeightTextField,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: DropdownButton(
                dropdownColor: Colors.white,
                focusColor: Colors.white,
                alignment: Alignment.center,
                underline: const SizedBox(),
                isExpanded: true,
                value: patternController.selectedBillType,
                items: InvoiceType.values.map((InvoiceType type) {
                  return DropdownMenuItem<InvoiceType>(
                    value: type,
                    child: Center(
                      child: Text(type.label, textDirection: TextDirection.rtl),
                    ),
                  );
                }).toList(),
                onChanged: patternController.onSelectedTypeChanged,
              )),
        ],
      ),
    );
  }
}
