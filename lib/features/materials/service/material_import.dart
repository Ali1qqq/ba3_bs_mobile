import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class MaterialImport extends ImportServiceBase<MaterialModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<MaterialModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> materialsJson = jsonContent['Materials']['M'] ?? [];

    return materialsJson.map((materialJson) => MaterialModel.fromJson(materialJson as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<MaterialModel>> fromImportXml(XmlDocument document) async {
    final materialsXml = document.findAllElements('M');
    final materialsGccXml = document.findAllElements('GCCMaterialTax');

    List<GccMatTax> gcc = materialsGccXml.map(
      (gccMat) {
        String getvalue(String tagName) {
          final elements = gccMat.findElements(tagName);
          return elements.isEmpty ? '' : elements.first.value ?? '';
        }

        return GccMatTax(vat: getvalue('GCCMaterialTaxRatio'), guid: getvalue('GCCMaterialTaxMatGUID'));
      },
    ).toList();

    List<MaterialModel> materials = materialsXml.map((materialElement) {
      String? getvalue(String tagName) {
        final elements = materialElement.findElements(tagName);
        return elements.isEmpty ? null : elements.first.value;
      }

      int? getInt(String tagName) {
        final value = getvalue(tagName);
        return value == null ? null : double.parse(value.toString()).toInt();
      }

      double? getDouble(String tagName) {
        final value = getvalue(tagName);
        return value == null ? null : double.parse(value);
      }

      DateTime? getDate(String tagName) {
        final value = getvalue(tagName);
        return value == null ? null : DateTime.parse(value);
      }

      return MaterialModel(
        id: getvalue('mptr') ?? '',
        matCode: getInt('MatCode'),
        matName: getvalue('MatName') ?? '',
        matBarCode: getvalue('MatBarCode') ?? '',
        matGroupGuid: getvalue('MatGroupGuid') ?? '',
        matUnity: getvalue('MatUnity'),
        matPriceType: getInt('MatPriceType'),
        matBonus: getInt('MatBonus'),
        matBonusOne: getInt('MatBonusOne'),
        matCurrencyGuid: getvalue('MatCurrencyGuid') ?? '',
        matCurrencyVal: getDouble('MatCurrencyVal'),
        matPictureGuid: getvalue('MatPictureGuid') ?? '',
        matType: getInt('MatType'),
        matSecurity: getInt('MatSecurity'),
        matFlag: getInt('MatFlag'),
        matExpireFlag: getInt('MatExpireFlag'),
        matProdFlag: getInt('MatProdFlag'),
        matUnit2FactFlag: getInt('MatUnit2FactFlag'),
        matUnit3FactFlag: getInt('MatUnit3FactFlag'),
        matSNFlag: getInt('MatSNFlag'),
        matForceInSN: getInt('MatForceInSN'),
        matForceOutSN: getInt('MatForceOutSN'),
        matVAT: getInt('MatVAT'),
        matDefUnit: getInt('MatDefUnit'),
        matBranchMask: getInt('MatBranchMask'),
        matAss: getInt('MatAss'),
        matOldGUID: getvalue('MatOldGUID') ?? '',
        matNewGUID: getvalue('MatNewGUID') ?? '',
        matCalPriceFromDetail: getInt('MatCalPriceFromDetail'),
        matForceInExpire: getInt('MatForceInExpire'),
        matForceOutExpire: getInt('MatForceOutExpire'),
        matCreateDate: getDate('MatCreateDate'),
        matIsIntegerQuantity: getInt('MatIsIntegerQuantity'),
        matClassFlag: getInt('MatClassFlag'),
        matForceInClass: getInt('MatForceInClass'),
        matForceOutClass: getInt('MatForceOutClass'),
        matDisableLastPrice: getInt('MatDisableLastPrice'),
        matLastPriceCurVal: getDouble('MatLastPriceCurVal'),
        matPrevQty: getvalue('MatPrevQty') ?? '',
        matFirstCostDate: getDate('MatFirstCostDate'),
        matHasSegments: getInt('MatHasSegments'),
        matParent: getvalue('MatParent') ?? '',
        matIsCompositionUpdated: getInt('MatIsCompositionUpdated'),
        matInheritsParentSpecs: getInt('MatInheritsParentSpecs'),
        matCompositionName: getvalue('MatCompositionName'),
        matCompositionLatinName: getvalue('MatCompositionLatinName'),
        movedComposite: getInt('MovedComposite'),
        wholesalePrice: getvalue('Whole2') ?? '',
        retailPrice: getvalue('retail2') ?? '',
        endUserPrice: getvalue('EndUser2') ?? '',
        matVatGuid: getvalue('MatVatGuid'),
      );
    }).toList();
    // log('material last ${materials.last.toJson()}');
    // log('material first ${materials.first.toJson()}');
    updateMaterialVat(materials, gcc);

    // log('materials ${materials.length}');
    // log('material last ${materials.last.toJson()}');
    // log('material first ${materials.first.toJson()}');

    return materials;
  }
}

class GccMatTax {
  final String vat;
  final String guid;

  GccMatTax({required this.vat, required this.guid});

  Map toJson() => {
        'vat': vat,
        'guid': guid,
      };

  GccMatTax copyWith({
    final String? vat,
    final String? guid,
  }) {
    return GccMatTax(
      vat: vat ?? this.vat,
      guid: guid ?? this.guid,
    );
  }
}

void updateMaterialVat(List<MaterialModel> materials, List<GccMatTax> gccList) {
  for (var i = 0; i < materials.length; i++) {
    var material = materials[i];

    // Find the corresponding VAT value for the material
    final gcc = gccList.firstWhere(
      (gccItem) => gccItem.guid == material.id,
      orElse: () => GccMatTax(vat: '0.00', guid: ''), // Default object with 0.00 VAT
    );

    MaterialModel updatedMaterial = material; // Initialize with original material

    // Check if gcc is found and update the matVatGuid
    if (gcc.vat.isNotEmpty && gcc.guid.isNotEmpty) {
      double vatValue = double.tryParse(gcc.vat) ?? 0.00; // Parse vat to double safely

      if (vatValue == 5.00) {
        updatedMaterial = material.copyWith(matVatGuid: 'xtc33mNeCZYR98i96pd8');
      } else if (vatValue == 0.00) {
        updatedMaterial = material.copyWith(matVatGuid: 'kCfkUHwNyRbxTlD71uXV');
      }

      // Update the material in the list if modified
      if (updatedMaterial != material) {
        materials[i] = updatedMaterial;
      }
    } else {
      // If no matching VAT, set default matVatGuid
      updatedMaterial = material.copyWith(matVatGuid: 'kCfkUHwNyRbxTlD71uXV');
      materials[i] = updatedMaterial;
    }
  }
}
