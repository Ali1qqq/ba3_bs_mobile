import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../data/models/seller_model.dart';

class SellerImport extends ImportServiceBase<SellerModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<SellerModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> materialsJson = jsonContent['Materials']['M'] ?? [];

    return materialsJson.map((materialJson) => SellerModel.fromLocalImport(materialJson as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SellerModel>> fromImportXml(XmlDocument document) async {
    final materialsXml = document.findAllElements('Q');

    List<SellerModel> sellers = materialsXml.map((materialElement) {
      String? getText(String tagName) {
        final elements = materialElement.findElements(tagName);
        return elements.isEmpty ? null : elements.first.text;
      }

      int? getInt(String tagName) {
        final text = getText(tagName);
        return text == null ? null : double.parse(text.toString()).toInt();
      }

      return SellerModel(
        costGuid: getText('CostGuid') ?? '',
        costCode: getInt('CostCode'),
        costName: getText('CostName') ?? '',
        costLatinName: getText('CostLatinName') ?? '',
        costParentGuid: getText('CostParentGuid') ?? '',
        costNote: getText('CostNote') ?? '',
        costDebit: getText('CostDebit') ?? '',
        costCredit: getText('CostCredit') ?? '',
        costType: getInt('CostType'),
        costSecurity: getInt('CostSecurity'),
        costRes1: getInt('CostRes1'),
        costRes2: getInt('CostRes2'),
        costBranchMask: getInt('CostBranchMask'),
        costIsChangeableRatio: getInt('CostIsChangeableRatio'),
      );
    }).toList();

    return sellers;
  }
}
