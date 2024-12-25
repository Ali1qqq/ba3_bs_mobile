import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../../core/widgets/app_spacer.dart';
import '../../../controllers/pluto/bond_details_pluto_controller.dart';

class BondDetailsCalculations extends StatelessWidget {
  const BondDetailsCalculations({super.key, required this.tag, required this.bondDetailsPlutoController});

  final String tag;
  final BondDetailsPlutoController bondDetailsPlutoController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BondDetailsPlutoController>(
      tag: tag,
      builder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const VerticalSpace(),
            SizedBox(
              width: 350,
              child: Row(
                children: [
                  const SizedBox(
                      width: 100,
                      child: Text(
                        "المجموع",
                      )),
                  Container(width: 120, color: bondDetailsPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red, padding: const EdgeInsets.all(5), child: Text(bondDetailsPlutoController.calcDebitTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                  const SizedBox(width: 10),
                  Container(width: 120, color: bondDetailsPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red, padding: const EdgeInsets.all(5), child: Text(bondDetailsPlutoController.calcCreditTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                ],
              ),
            ),
            const VerticalSpace(
              5,
            ),
            SizedBox(
              width: 350,
              child: Row(
                children: [
                  const SizedBox(width: 100, child: Text("الفرق")),
                  Container(
                      width: 250,
                      color: bondDetailsPlutoController.checkIfBalancedBond() ? Colors.green : Colors.red,
                      padding: const EdgeInsets.all(5),
                      child: Text(bondDetailsPlutoController.getDefBetweenCreditAndDebt().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
