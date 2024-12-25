import 'package:flutter/material.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../controllers/cheques/cheques_details_controller.dart';

class ChequesDetailsHeader extends StatelessWidget {
  const ChequesDetailsHeader({
    super.key,
    required this.chequesDetailsController,
  });

  final ChequesDetailsController chequesDetailsController;

  @override
  Widget build(BuildContext context) {
    return TextAndExpandedChildField(
      label: 'الحالة ',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: chequesDetailsController.isPayed! ? Colors.green : Colors.red, border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(4)),
        child: Center(
            child: Text(
          chequesDetailsController.isPayed! ? ChequesStatus.paid.label : ChequesStatus.notPaid.label,
          style: const TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
