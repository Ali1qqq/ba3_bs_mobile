import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/profile/ui/widgets/profile_info_row_shimmer_widget.dart';
import 'package:ba3_bs_mobile/features/profile/ui/widgets/profile_info_row_widget.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/user_target.dart';
import '../../../../core/widgets/user_target_shimmer_widget.dart';
import '../../../main_layout/ui/widgets/main_header.dart';
import '../../../user_time/ui/widgets/layout_widgets/add_time_widget.dart';
import '../../../user_time/ui/widgets/layout_widgets/holidays_widget.dart';
import '../../../user_time/ui/widgets/layout_widgets/user_daily_time_widget.dart';
import '../../controller/user_time_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = read<UserManagementController>().loggedInUserModel!;
    final salesController = read<SellerSalesController>();
    salesController.onSelectSeller(sellerId: read<UserManagementController>().loggedInUserModel?.userSellerId).then(
          (value) => salesController.calculateTotalAccessoriesMobiles(),
        );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Obx(() {
            return salesController.profileScreenState.value == RequestState.loading
                ? ListView(
                    shrinkWrap: true,
                    children: List.generate(
                      10,
                      (index) => Column(
                        children: [
                          ProfileInfoRowShimmerWidget(),
                          VerticalSpace(),
                        ],
                      ),
                    ),
                  )
                : Column(
                    spacing: 10,
                    children: [
                      ProfileInfoRowWidget(
                        label: AppStrings.userName.tr,
                        value: currentUser.userName.toString(),
                      ),
                      ProfileInfoRowWidget(
                        label: AppStrings.password.tr,
                        value: currentUser.userPassword.toString(),
                      ),
                      ProfileInfoRowWidget(
                        label: AppStrings.totalSales.tr,
                        value: (salesController.totalAccessoriesSales + salesController.totalMobilesSales).toString(),
                      ),
                      AddTimeWidget(
                        userTimeController: read<UserTimeController>(),
                      ),
                      HolidaysWidget(
                        userTimeController: read<UserTimeController>(),
                      ),
                      UserDailyTimeWidget(
                        userModel: read<UserTimeController>().getUserById()!,
                      ),
                      /*


                      Spacer(),
                    */
                      Obx(() {
                        return salesController.profileScreenState.value == RequestState.loading
                            ? UserTargetShimmerWidget()
                            : UserTargets(salesController: salesController);
                      }),
                      const MainHeader(),
                    ],
                  );
          }),
        ),
      ),
    );
  }
}