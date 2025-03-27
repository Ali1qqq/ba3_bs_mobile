import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';

class ChartBoxWidget extends StatelessWidget {
  const ChartBoxWidget({
    super.key,
    required this.color,
    required this.text,
    required this.totals,
    this.onTap,
  });

  final String text;
  final String totals;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          HorizontalSpace(20),
          Container(
            height: 13,
            width: 13,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
          ),
          SizedBox(
            width: 18.w,
            child: Text(
              totals.formatNumber(),
              style: AppTextStyles.headLineStyle3,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            text,
            style: AppTextStyles.headLineStyle3,
          ),
        ],
      ),
    );
  }
}

class ChartColumn extends StatelessWidget {
  final List<ChartItem> items;

  const ChartColumn({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => ChartBoxWidget(
                color: item.color,
                text: item.text,
                totals: item.total,
                onTap: item.onTap,
              ))
          .toList(),
    );
  }
}

class ChartItem {
  final Color color;
  final String text;
  final String total;
  final VoidCallback? onTap;

  ChartItem({required this.color, required this.text, required this.total, this.onTap});
}