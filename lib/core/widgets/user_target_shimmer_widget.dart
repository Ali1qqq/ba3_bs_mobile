import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/widgets/user_target.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserTargetShimmerWidget extends StatelessWidget {
  final double width;

  const UserTargetShimmerWidget({
    super.key,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: UserTargets(
        salesController: read<SellerSalesController>(),
      ),
    );
  }
}