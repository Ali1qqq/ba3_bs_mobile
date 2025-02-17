import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/customer/data/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';

class CustomerItemWidget extends StatelessWidget {
  const CustomerItemWidget({super.key, required this.customerModel, required this.onDelete});

  final CustomerModel customerModel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(
              AppStrings.customerName.tr,
              style: AppTextStyles.headLineStyle3,
            ),
            HorizontalSpace(),
            Container(
              height: 30,
              width: 150,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey, width: 2)),
              child: Center(
                child: Text(
                  customerModel.name ?? '',
                  style: AppTextStyles.headLineStyle3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              AppStrings.mobileNumber.tr,
              style: AppTextStyles.headLineStyle3,
            ),
            HorizontalSpace(),
            Container(
              height: 30,
              width: 150,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey, width: 2)),
              child: Center(
                child: Text(
                  customerModel.phone1 ?? '',
                  style: AppTextStyles.headLineStyle3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              AppStrings.taxType.tr,
              style: AppTextStyles.headLineStyle3,
            ),
            HorizontalSpace(),
            Container(
              height: 30,
              width: 250,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey, width: 2)),
              child: Center(
                child: Text(
                  VatEnums.byGuid(customerModel.cusVatGuid!).taxName ?? '',
                  style: AppTextStyles.headLineStyle3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        IconButton(onPressed: onDelete, icon: Icon(Icons.delete))
      ],
    );
  }
}