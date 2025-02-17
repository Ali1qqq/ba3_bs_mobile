import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../controllers/accounts_controller.dart';
import 'customer_item_widget.dart';

class AddCustomersWidget extends StatelessWidget {
  const AddCustomersWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = read<AccountsController>();
    return SizedBox(
      height: 300,
      child: Obx(
            () {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrganizedWidget(
              titleWidget: Center(
                child: Text(
                  AppStrings.customers.tr,
                  style: AppTextStyles.headLineStyle2,
                ),
              ),
              bodyWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.toggleAddCustomerForm,
                      icon: Row(
                        children: [
                          Icon(
                            controller.showAddCustomerForm.value ? Icons.close : Icons.add,
                            size: 12,
                            color: AppColors.blueColor,
                          ),
                          HorizontalSpace(),
                          Text(
                            controller.showAddCustomerForm.value ? AppStrings.hide.tr : AppStrings.add.tr,
                            style: AppTextStyles.headLineStyle4.copyWith(fontSize: 12, color: AppColors.blueColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (controller.showAddCustomerForm.value)
                    Column(
                      spacing: 10,
                      children: [
                        FormFieldRow(
                          spacing: 40,
                          firstItem: TextAndExpandedChildField(
                            label: AppStrings.customerName.tr,
                            child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,
                              suffixIcon: const SizedBox(),
                              textEditingController: controller.newCustomerNameController,
                              // validator: (value) => controller.defaultValidator(value, "اسم العميل"),
                            ),
                          ),
                          secondItem: TextAndExpandedChildField(
                            label: AppStrings.mobileNumber.tr,
                            child: CustomTextFieldWithoutIcon(
                              filedColor: AppColors.backGroundColor,

                              suffixIcon: const SizedBox(),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              textEditingController: controller.newCustomerPhoneController,
                              //    validator: (value) => controller.defaultValidator(value, "رقم العميل"),
                            ),
                          ),
                        ),
                        VerticalSpace(),
                        TextAndExpandedChildField(
                          label: AppStrings.taxType.tr,
                          height: 40,
                          child: Container(
                              color: AppColors.backGroundColor,
                              child: DropdownButtonFormField<VatEnums>(
                                value: controller.selectedVat.value,
                                alignment: Alignment.center,

                                isExpanded: true,
                                items: VatEnums.values.map((vat) {
                                  return DropdownMenuItem<VatEnums>(
                                    value: vat,
                                    child: Center(
                                      child: Text(
                                        vat.taxName!,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: controller.onSelectedVatChanged,
                              )

                          ),
                        ),
                        VerticalSpace(20),
                        OutlinedButton(
                          onPressed: () {
                            controller.addNewCustomer();
                          },
                          child: Text(
                            AppStrings.save.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (controller.addedCustomers.isNotEmpty && !controller.showAddCustomerForm.value)
                    ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) =>
                          CustomerItemWidget(
                            customerModel: controller.addedCustomers[index],
                            onDelete: () => controller.deleteCustomer(customer: controller.addedCustomers[index]),
                          ),
                      separatorBuilder: (context, index) => VerticalSpace(),
                      itemCount: controller.addedCustomers.length,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}