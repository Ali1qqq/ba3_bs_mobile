import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';

class AddBillAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AddBillAppBar({
    super.key,
    required this.addBillController,
    required this.billTypeModel,
    required this.fromBillDetails,
    required this.fromBillById,
  });

  final AddBillController addBillController;
  final BillTypeModel billTypeModel;
  final bool fromBillDetails;
  final bool fromBillById;

  // kToolbarHeight: default AppBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      centerTitle: true,
      // leading: BackButton(
      //   onPressed: () {
      //     addBillController.onBackPressed(
      //       billTypeId: billTypeModel.billTypeId!,
      //       fromBillDetails: fromBillDetails,
      //       fromBillById: fromBillById,
      //     );
      //   },
      // ),
      title: Text('${billTypeModel.fullName}'),
      actions: [
        SizedBox(
          height: AppConstants.constHeightTextField,
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        "نوع الفاتورة" ": ",
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Expanded(
                      child: Container(
                          height: AppConstants.constHeightTextField,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black38),
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            underline: const SizedBox(),
                            value: addBillController.selectedPayType,
                            isExpanded: true,
                            onChanged: (payType) => addBillController.onPayTypeChanged(payType),
                            items: InvPayType.values
                                .map((InvPayType type) => DropdownMenuItem<InvPayType>(
                                      value: type,
                                      child: SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            type.label,
                                            textDirection: TextDirection.rtl,
                                          )),
                                    ))
                                .toList(),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const HorizontalSpace(20),
      ],
    );
  }
}
