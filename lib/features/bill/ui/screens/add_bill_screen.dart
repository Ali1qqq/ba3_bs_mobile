import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bill/add_bill_controller.dart';
import '../../controllers/pluto/add_bill_pluto_controller.dart';
import '../widgets/add_bill/add_bill_app_bar.dart';
import '../widgets/add_bill/add_bill_body.dart';
import '../widgets/add_bill/add_bill_buttons.dart';
import '../widgets/add_bill/add_bill_calculations.dart';
import '../widgets/add_bill/add_bill_header.dart';

class AddBillScreen extends StatelessWidget {
  const AddBillScreen({
    super.key,
    required this.billTypeModel,
    required this.fromBillDetails,
    required this.fromBillById,
    required this.addBillController,
    required this.addBillPlutoController,
    required this.tag,
  });

  final BillTypeModel billTypeModel;
  final bool fromBillDetails;
  final bool fromBillById;
  final AddBillController addBillController;
  final AddBillPlutoController addBillPlutoController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddBillController>(
        tag: tag,
        builder: (_) {
          return Scaffold(
            appBar: AddBillAppBar(
              billTypeModel: billTypeModel,
              fromBillDetails: fromBillDetails,
              fromBillById: fromBillById,
              addBillController: addBillController,
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      AddBillHeader(addBillController: addBillController),
                      const VerticalSpace(5),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AddBillBody(
                          billTypeModel: billTypeModel,
                          addBillController: addBillController,
                          addBillPlutoController: addBillPlutoController,
                          tag: tag,
                        ),
                      ),
                      const VerticalSpace(5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AddBillCalculations(
                          addBillPlutoController: addBillPlutoController,
                          tag: tag,
                        ),
                      ),
                      const Divider(height: 10),
                      AddBillButtons(addBillController: addBillController, billTypeModel: billTypeModel),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
