import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';
import 'package:ba3_bs_mobile/features/bond/ui/widgets/bond_details/bond_details_app_bar.dart';
import 'package:ba3_bs_mobile/features/bond/ui/widgets/bond_details/bond_details_body.dart';
import 'package:ba3_bs_mobile/features/bond/ui/widgets/bond_details/bond_details_buttons.dart';
import 'package:ba3_bs_mobile/features/bond/ui/widgets/bond_details/bond_details_calculations.dart';
import 'package:ba3_bs_mobile/features/bond/ui/widgets/bond_details/bond_details_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bonds/bond_search_controller.dart';
import '../../controllers/pluto/bond_details_pluto_controller.dart';

class BondDetailsScreen extends StatelessWidget {
  const BondDetailsScreen({
    super.key,
    required this.fromBondById,
    required this.bondDetailsController,
    required this.bondDetailsPlutoController,
    required this.bondSearchController,
    required this.tag,
  });

  final bool fromBondById;
  final BondDetailsController bondDetailsController;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final BondSearchController bondSearchController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BondSearchController>(
        tag: tag,
        builder: (_) {
          final BondModel currentBond = bondSearchController.getCurrentBond;

          return GetBuilder<BondDetailsController>(
              tag: tag,
              builder: (_) {
                return Scaffold(
                  appBar: BondDetailsAppBar(
                      bondDetailsController: bondDetailsController,
                      bondSearchController: bondSearchController,
                      bondTypeModel: BondType.byTypeGuide(currentBond.payTypeGuid!)),
                  body: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          BondDetailsHeader(
                            bondDetailsController: bondDetailsController,
                          ),
                          BondDetailsBody(
                            bondTypeModel: BondType.byTypeGuide(currentBond.payTypeGuid!),
                            bondDetailsController: bondDetailsController,
                            bondDetailsPlutoController: bondDetailsPlutoController,
                            tag: tag,
                          ),
                          BondDetailsCalculations(
                            tag: tag,
                            bondDetailsPlutoController: bondDetailsPlutoController,
                          ),
                          BondDetailsButtons(
                            bondDetailsController: bondDetailsController,
                            bondDetailsPlutoController: bondDetailsPlutoController,
                            bondModel: currentBond,
                            fromBondById: fromBondById,
                            bondSearchController: bondSearchController,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
