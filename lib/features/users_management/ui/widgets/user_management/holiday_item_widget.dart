import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_text_style.dart';

class HolidayItemWidget extends StatelessWidget {
  const HolidayItemWidget({super.key, required this.holiday, required this.onDelete});

  final String holiday;

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.grayColor,
            ),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              holiday,
              style: AppTextStyles.headLineStyle3,
            ),
            InkWell(
                onTap: onDelete,
                child: Icon(
                  Icons.delete,
                ))
          ],
        ),
      ),
    );
  }
}
