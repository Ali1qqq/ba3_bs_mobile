import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_format_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class ChequesImport extends ImportServiceBase<ChequesModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<ChequesModel> fromImportJson(Map<String, dynamic> jsonContent) {
    return [];
  }

  @override
  Future<List<ChequesModel>> fromImportXml(XmlDocument document) async {
    final chequesElements = document.findAllElements('H');
    return chequesElements.map((element) {
      final checkCollectEntries = element.findElements('CheckCollectEntry');
      String? chequesPayGuid;
      String? chequesPayDate;
      if (checkCollectEntries.isNotEmpty) {
        for (var element in checkCollectEntries) {
          chequesPayGuid = element.firstElementChild!.findElements('CEntryGuid').first.value;
          chequesPayDate = element.firstElementChild!.findElements('CEntryDate').first.value;
        }
      }

      return ChequesModel(
        chequesTypeGuid: element.findElements('CheckTypeGuid').first.value,
        chequesNumber: int.tryParse(element.findElements('CheckNumber').first.value!),
        chequesNum: int.tryParse(element.findElements('CheckNum').first.value!),
        chequesGuid: element.findElements('CheckGuid').first.value,
        chequesDate: element.findElements('CheckDate').first.value!.toYearMonthDayFormat(),
        chequesDueDate: element.findElements('CheckDueDate').first.value!.toYearMonthDayFormat(),
        chequesNote: element.findElements('CheckNote').first.value,
        chequesVal: double.tryParse(element.findElements('CheckVal').first.value!),
        chequesAccount2Guid: element.findElements('CheckAccount2Guid').first.value,
        accPtr: element.findElements('AccPtr').first.value,
        isPayed: checkCollectEntries.isNotEmpty,
        chequesPayGuid: checkCollectEntries.isNotEmpty ? chequesPayGuid : null,
        chequesPayDate: checkCollectEntries.isNotEmpty ? chequesPayDate!.toYearMonthDayFormat() : null,
        accPtrName: read<AccountsController>().getAccountNameById(element.findElements('AccPtr').first.value),
        chequesAccount2Name: read<AccountsController>().getAccountNameById(element.findElements('CheckAccount2Guid').first.value),
      );
    }).toList();
  }
}