import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bonds/bond_details_controller.dart';
import '../../../controllers/bonds/bond_search_controller.dart';
import '../../../controllers/pluto/bond_details_pluto_controller.dart';
import '../../../data/models/bond_model.dart';

class BondDetailsButtons extends StatelessWidget {
  const BondDetailsButtons({
    super.key,
    required this.bondDetailsController,
    required this.bondDetailsPlutoController,
    required this.bondModel,
    required this.fromBondById,
    required this.bondSearchController,
  });

  final BondDetailsController bondDetailsController;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final BondSearchController bondSearchController;
  final BondModel bondModel;
  final bool fromBondById;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 20,
        runSpacing: 20,
        children: [
          Obx(() {
            return AppButton(
                title: bondDetailsController.isBondSaved.value ? 'جديد' : 'إضافة',
                height: 20,
                color: bondDetailsController.isBondSaved.value ? Colors.green : Colors.blue.shade700,
                onPressed: bondDetailsController.isBondSaved.value
                    ? () => bondDetailsController.appendNewBill(
                        bondType: BondType.byTypeGuide(bondModel.payTypeGuid!), lastBondNumber: bondSearchController.bonds.last.payNumber!)
                    : () async {
                        await bondDetailsController.saveBond(BondType.byTypeGuide(bondModel.payTypeGuid!));
                      },
                iconData: Icons.add_chart_outlined);
          }),
          if (!bondSearchController.isNew) ...[
            AppButton(
              title: 'السند',
              height: 20,
              onPressed: () async {
                bondDetailsController.createEntryBond(bondModel, context);
              },
              iconData: Icons.file_open_outlined,
            ),
            AppButton(
              title: "تعديل",
              height: 20,
              onPressed: () async {
                bondDetailsController.updateBond(
                  bondType: BondType.byTypeGuide(bondModel.payTypeGuid!),
                  bondModel: bondModel,
                );
              },
              iconData: Icons.edit_outlined,
            ),
            if (!bondSearchController.isNew)
              AppButton(
                title: 'Pdf-Email',
                height: 20,
                onPressed: () {
                  bondDetailsController.generateAndSendBondPdf(bondModel);
                },
                iconData: Icons.link,
              ),
            AppButton(
              iconData: Icons.delete_outline,
              height: 20,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {
                bondDetailsController.deleteBond(bondModel, fromBondById: fromBondById);
              },
            ),
          ]
        ],
      ),
    );
  }
}
