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
  List<ChequesModel> fromImportXml(XmlDocument document) {
    final chequesElements = document.findAllElements('H');
    return chequesElements.map((element) {
      return ChequesModel(
        chequesTypeGuid: element.findElements('CheckTypeGuid').first.value,
        chequesNumber: int.tryParse(element.findElements('CheckNumber').first.value ?? ''),
        chequesNum: int.tryParse(element.findElements('CheckNum').first.value ?? ''),
        chequesGuid: element.findElements('CheckGuid').first.value,
        chequesDate: element.findElements('CheckDate').first.value,
        chequesDueDate: element.findElements('CheckDueDate').first.value,
        chequesNote: element.findElements('CheckNote').first.value,
        chequesVal: double.tryParse(element.findElements('CheckVal').first.value ?? ''),
        chequesAccount2Guid: element.findElements('CheckAccount2Guid').first.value,
        accPtr: element.findElements('AccPtr').first.value,
        accPtrName: null,
        chequesAccount2Name: null,
      );
    }).toList();
  }
}
