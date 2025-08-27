import 'package:flutter/material.dart';

import '../../../../../core/helper/extensions/basic/string_extension.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../controller/seller_dashboard_controller.dart';

class SellersSalesTable extends StatelessWidget {
  final SellerDashboardController controller;

  const SellersSalesTable({super.key, required this.controller});

  Color _getTargetColor(double value, List<int> targets) {
    if (value < targets[0]) return Colors.black;
    if (value < targets[1]) return Colors.orange;
    if (value < targets[2]) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final sellers = controller.sellerChartData;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.all(16),
        // height: 600.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.backGroundColor.withValues(alpha: 0.1)),
          columns: [
            DataColumn(label: Text("البائع", style: AppTextStyles.headLineStyle1.copyWith(color: AppColors.feesSaleColor))),
            DataColumn(label: Text("إكسسوارات", style: AppTextStyles.headLineStyle1.copyWith(color: AppColors.feesSaleColor))),
            DataColumn(label: Text("موبايلات", style: AppTextStyles.headLineStyle1.copyWith(color: AppColors.feesSaleColor))),
            DataColumn(label: Text("الربح الكلي", style: AppTextStyles.headLineStyle1.copyWith(color: AppColors.feesSaleColor))),
          ],
          rows: sellers.map((seller) {
            final accessories = seller.totalAccessorySales;
            final mobiles = seller.totalMobileSales;
            final profit = accessories + mobiles;

            return DataRow(
              cells: [
                DataCell(Text(seller.sellerName, style: AppTextStyles.headLineStyle2)),
                DataCell(
                  Text(
                    accessories.toString().formatNumber(),
                    style: AppTextStyles.headLineStyle2.copyWith(
                      color: _getTargetColor(accessories.toDouble(), [75000, 150000, 200000]),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    mobiles.toString().formatNumber(),
                    style: AppTextStyles.headLineStyle2.copyWith(
                      color: _getTargetColor(mobiles.toDouble(), [150000, 250000, 350000]),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    profit.toString().formatNumber(),
                    style: AppTextStyles.headLineStyle2.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}