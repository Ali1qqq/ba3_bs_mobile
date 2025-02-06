import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_group.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class MaterialGroupImport extends ImportServiceBase<MaterialGroupModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<MaterialGroupModel> fromImportJson(Map<String, dynamic> jsonContent) {
    return [];
  }

  @override
  Future<List<MaterialGroupModel>> fromImportXml(XmlDocument document) async {
    final materialsXml = document.findAllElements('G');

    List<MaterialGroupModel> materials = materialsXml.map((materialElement) {
      String? getValue(String tagName) {
        final elements = materialElement.findElements(tagName);
        return elements.isEmpty ? null : elements.first.value;
      }

      int getInt(String tagName) {
        final value = getValue(tagName);
        return value == null ? 0 : double.parse(value.toString()).toInt();
      }

      double? getDouble(String tagName) {
        final value = getValue(tagName);
        return value == null ? null : double.parse(value);
      }

      return MaterialGroupModel(
        matGroupGuid: getValue('gPtr') ?? '',
        groupBranchMask: getInt('GroupBranchMask'),
        groupCode: getValue('GroupCode') ?? '',
        groupLatinName: getValue('GroupLatinName') ?? '',
        groupName: getValue('GroupName') ?? '',
        groupNotes: getValue('GroupNotes') ?? '',
        groupNumber: getInt('GroupNumber'),
        groupSecurity: getInt('GroupSecurity'),
        groupType: getInt('GroupType'),
        groupVat: getDouble('GroupVat') ?? 0.0,
        parentGuid: getValue('ParentGuid') ?? '',
      );
    }).toList();

    return materials;
  }
}
