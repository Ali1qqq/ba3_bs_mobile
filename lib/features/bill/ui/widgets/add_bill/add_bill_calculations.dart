import 'package:ba3_bs_mobile/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../bill_shared/calculation_card.dart';

class AddBillCalculations extends StatelessWidget {
  const AddBillCalculations({
    super.key,
    required this.addBillPlutoController,
    required this.tag,
  });

  final AddBillPlutoController addBillPlutoController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddBillPlutoController>(
        tag: tag,
        builder: (_) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            alignment: WrapAlignment.end,
            runSpacing: 10.0,
            children: [
              CalculationCard(
                height: 70.h,
                color: Colors.blueGrey.shade400,
                value:
                    addBillPlutoController.computeTotalVat.toStringAsFixed(2),
                label: 'القيمة المضافة',
              ),
              CalculationCard(
                height: 70.h,
                color: Colors.blueGrey.shade400,
                value: addBillPlutoController.computeBeforeVatTotal
                    .toStringAsFixed(2),
                label: 'المجموع قبل الضريبة',
              ),
              CalculationCard(
                height: 70.h,
                color: Colors.grey.shade600,
                value: addBillPlutoController.computeWithVatTotal
                    .toStringAsFixed(2),
                label: 'النهائي الجزئي',
              ),
              CalculationCard(
                width: 60.0.w,
                height: 70.h,
                color: Colors.blue,
                value: addBillPlutoController.calculateFinalTotal
                    .toStringAsFixed(2),
                label: 'النهائي',
              ),
            ],
          );
        });
  }
}
