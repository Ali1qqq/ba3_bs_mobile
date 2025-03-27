import 'dart:developer';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../cheques/data/models/cheques_model.dart';

class CopyUnpaidChequesUseCase {
  final Future<List<ChequesModel>> Function() fetchChequesByType;
  final Future<void> Function(List<ChequesModel>, ChequesType) saveAllCheques;
  final bool Function(String) migrationGuard;
  final void Function(String version) setCurrentVersion;

  CopyUnpaidChequesUseCase({
    required this.fetchChequesByType,
    required this.saveAllCheques,
    required this.migrationGuard,
    required this.setCurrentVersion,
  });

  Future<void> execute(String currentYear) async {
    if (migrationGuard(currentYear)) return;

    // Temporarily switch to default version to fetch cheques
    setCurrentVersion(AppConstants.defaultVersion);

    final fetchedCheques = await fetchChequesByType();

    final unpaidCheques = fetchedCheques
        .where((cheque) =>
            (cheque.isPayed == false || cheque.isPayed == null) && (cheque.isRefund == false || cheque.isRefund == null))
        .toList();

    log("fetchedCheques is \${fetchedCheques.length}", name: "CopyUnpaidChequesUseCase");
    log("unpaidCheques is \${unpaidCheques.length}", name: "CopyUnpaidChequesUseCase");

    // Restore current version
    setCurrentVersion(currentYear);

    if (migrationGuard(currentYear)) return;

    await saveAllCheques(unpaidCheques, ChequesType.paidChecks);

    log("\uD83D\uDCCC تم نقل الشيكات الغير المقبوضة والغير المدفوعة.", name: "CopyUnpaidChequesUseCase");
  }
}
