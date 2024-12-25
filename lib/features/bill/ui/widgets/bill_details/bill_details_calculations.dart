import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../bill_shared/calculation_card.dart';

class BillDetailsCalculations extends StatelessWidget {
  const BillDetailsCalculations({
    super.key,
    required this.tag,
    required this.billDetailsPlutoController,
  });

  final String tag;
  final BillDetailsPlutoController billDetailsPlutoController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillDetailsPlutoController>(
      tag: tag,
      builder: (_) => Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        alignment: WrapAlignment.end,
        runSpacing: 10.0,
        children: [
          CalculationCard(
            height: 60.h,
            color: Colors.blueGrey.shade400,
            value: billDetailsPlutoController.computeTotalVat.toStringAsFixed(2),
            label: 'القيمة المضافة',
          ),
          CalculationCard(
            height: 60.h,
            color: Colors.blueGrey.shade400,
            value: billDetailsPlutoController.computeBeforeVatTotal.toStringAsFixed(2),
            label: 'المجموع قبل الضريبة',
          ),
          CalculationCard(
            height: 60.h,
            color: Colors.grey.shade600,
            value: billDetailsPlutoController.computeWithVatTotal.toStringAsFixed(2),
            label: 'النهائي الجزئي',
          ),
          CalculationCard(
            width: 60.0.w,
            height: 60.h,
            color: Colors.blue,
            value: billDetailsPlutoController.calculateFinalTotal.toStringAsFixed(2),
            label: 'النهائي',
          ),
        ],
      ),
    );
  }
}
