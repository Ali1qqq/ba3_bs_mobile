import 'package:ba3_bs_mobile/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../bill_shared/calculation_card.dart';

class BillDetailsCalculations extends StatelessWidget {
  const BillDetailsCalculations({
    super.key,
    required this.tag,
    required this.billDetailsPlutoController,
    required this.billTypeModel,
  });

  final String tag;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillTypeModel billTypeModel;

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
            visible: billTypeModel.billPatternType!.hasVat,
            color: Colors.blueGrey.shade400,
            value: billDetailsPlutoController.computeTotalVat.toStringAsFixed(2),
            label: AppStrings.addedValue.tr,
          ),
          CalculationCard(
            visible: billTypeModel.billPatternType!.hasVat,
            color: Colors.blueGrey.shade400,
            value: billDetailsPlutoController.computeBeforeVatTotal.toStringAsFixed(2),
            label: AppStrings.totalBeforeTax.tr,
          ),
          CalculationCard(
            visible: billTypeModel.billPatternType!.hasVat,
            color: Colors.grey.shade600,
            value: billDetailsPlutoController.computeWithVatTotal.toStringAsFixed(2),
            label: AppStrings.subtotal.tr,
          ),
          CalculationCard(
            width: 60.0.w,
            color: Colors.blue,
            value: billDetailsPlutoController.calculateFinalTotal.toStringAsFixed(2),
            label: AppStrings.total.tr,
          ),
        ],
      ),
    );
  }
}