import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      width: 1.sw,
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('نوع الفاتورة')),
          Expanded(
            child: Container(
                width: 1.sw - 100,
                height: AppConstants.constHeightTextField,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: DropdownButton(
                  hint: const Text('اختار نوع النمط'),
                  dropdownColor: Colors.white,
                  focusColor: Colors.white,
                  alignment: Alignment.center,
                  underline: const SizedBox(),
                  isExpanded: true,
                  value: patternController.patternFormHandler.selectedBillPatternType,
                  items: BillPatternType.values.map((BillPatternType type) {
                    return DropdownMenuItem<BillPatternType>(
                      value: type,
                      child: Center(
                        child: Text(type.label, textDirection: TextDirection.rtl),
                      ),
                    );
                  }).toList(),
                  onChanged: patternController.patternFormHandler.onSelectedTypeChanged,
                )),
          ),
        ],
      ),
    );
  }
}
