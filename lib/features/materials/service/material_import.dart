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
        String getText(String tagName) {
          final elements = gccMat.findElements(tagName);
          return elements.isEmpty ? '' : elements.first.value!;
        }

        return GccMatTax(vat: getText('GCCMaterialTaxRatio'), guid: getText('GCCMaterialTaxMatGUID'));
      },
    ).toList();

    List<MaterialModel> materials = materialsXml.map((materialElement) {
      String? getText(String tagName) {
        final elements = materialElement.findElements(tagName);
        return elements.isEmpty ? null : elements.first.value;
      }

      int? getInt(String tagName) {
        final text = getText(tagName);
        return text == null ? null : double.parse(text.toString()).toInt();
      }

      double? getDouble(String tagName) {
        final text = getText(tagName);
        return text == null ? null : double.parse(text);
      }

      DateTime? getDate(String tagName) {
        final text = getText(tagName);
        return text == null ? null : DateTime.parse(text);
      }

      return MaterialModel(
        id: getText('mptr') ?? '',
        matCode: getInt('MatCode'),
        matName: getText('MatName') ?? '',
        matBarCode: getText('MatBarCode') ?? '',
        matGroupGuid: getText('MatGroupGuid') ?? '',
        matUnity: getText('MatUnity'),
        matPriceType: getInt('MatPriceType'),
        matBonus: getInt('MatBonus'),
        matBonusOne: getInt('MatBonusOne'),
        matCurrencyGuid: getText('MatCurrencyGuid') ?? '',
        matCurrencyVal: getDouble('MatCurrencyVal'),
        matPictureGuid: getText('MatPictureGuid') ?? '',
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
        matOldGUID: getText('MatOldGUID') ?? '',
        matNewGUID: getText('MatNewGUID') ?? '',
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
        matPrevQty: getText('MatPrevQty') ?? '',
        matFirstCostDate: getDate('MatFirstCostDate'),
        matHasSegments: getInt('MatHasSegments'),
        matParent: getText('MatParent') ?? '',
        matIsCompositionUpdated: getInt('MatIsCompositionUpdated'),
        matInheritsParentSpecs: getInt('MatInheritsParentSpecs'),
        matCompositionName: getText('MatCompositionName'),
        matCompositionLatinName: getText('MatCompositionLatinName'),
        movedComposite: getInt('MovedComposite'),
        wholesalePrice: getText('Whole2') ?? '',
        retailPrice: getText('retail2') ?? '',
        endUserPrice: getText('EndUser2') ?? '',
        matVatGuid: getText('MatVatGuid'),
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