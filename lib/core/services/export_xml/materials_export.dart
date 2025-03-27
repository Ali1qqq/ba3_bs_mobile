import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/materials/data/models/materials/material_model.dart';

/// A class responsible for exporting material data into an XML format.
class MaterialsExport {
  /// Generates the Materials section of the export XML.
  ///
  /// This method takes a list of [MaterialModel] objects and converts them into an XML element
  /// with the tag 'Materials'. Each material is transformed into an 'M' element using the helper
  /// method [_buildMaterialElement].
  ///
  /// Parameters:
  /// - [materials]: A list of [MaterialModel] objects to be exported.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the Materials section.
  xml.XmlElement exportMaterials(List<MaterialModel> materials) {
    return xml.XmlElement(
      xml.XmlName('Materials'),
      [],
      materials.map((mat) => _buildMaterialElement(mat)).toList(),
    );
  }

  /// Builds an XML element for a single material.
  ///
  /// This helper method converts a [MaterialModel] into an XML element with the tag 'M'. It maps
  /// each property of the material to a corresponding XML element using [XmlHelpers.element]. Default
  /// values are provided for nullable properties when necessary.
  ///
  /// Parameters:
  /// - [mat]: A [MaterialModel] instance containing the material data.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing a single material.
  xml.XmlElement _buildMaterialElement(MaterialModel mat) {
    return xml.XmlElement(
      xml.XmlName('M'),
      [],
      [
        // Unique material pointer.
        XmlHelpers.element('mptr', mat.id),
        // Material code as string.
        XmlHelpers.element('MatCode', mat.matCode?.toString()),
        // Material name.
        XmlHelpers.element('MatName', mat.matName),
        // Material barcode.
        XmlHelpers.element('MatBarCode', mat.matBarCode),
        // GUID of the material group.
        XmlHelpers.element('MatGroupGuid', mat.matGroupGuid),
        // Unit of measure for the material.
        XmlHelpers.element('MatUnity', mat.matUnity),
        // Material price type as string.
        XmlHelpers.element('MatPriceType', mat.matPriceType?.toString()),
        // Bonus value for the material; defaults to '0'.
        XmlHelpers.element('MatBonus', mat.matBonus?.toString() ?? '0'),
        // Bonus multiplier; defaults to '1'.
        XmlHelpers.element('MatBonusOne', mat.matBonusOne?.toString() ?? '1'),
        // GUID for the material currency.
        XmlHelpers.element('MatCurrencyGuid', mat.matCurrencyGuid),
        // Currency value for the material; defaults to '1'.
        XmlHelpers.element('MatCurrencyVal', mat.matCurrencyVal?.toString() ?? '1'),
        // Picture GUID for the material; defaults to a standard GUID if null.
        XmlHelpers.element('MatPictureGuid', mat.matPictureGuid ?? '00000000-0000-0000-0000-000000000000'),
        // Material type as string; defaults to '0'.
        XmlHelpers.element('MatType', mat.matType?.toString() ?? '0'),
        // Security level for the material; defaults to '1'.
        XmlHelpers.element('MatSecurity', mat.matSecurity?.toString() ?? '1'),
        // Flag for the material; defaults to '0'.
        XmlHelpers.element('MatFlag', mat.matFlag?.toString() ?? '0'),
        // Expiration flag; defaults to '0'.
        XmlHelpers.element('MatExpireFlag', mat.matExpireFlag?.toString() ?? '0'),
        // Production flag; defaults to '0'.
        XmlHelpers.element('MatProdFlag', mat.matProdFlag?.toString() ?? '0'),
        // Serial number flag; defaults to '-1' if not provided.
        XmlHelpers.element('MatSNFlag', mat.matSNFlag?.toString() ?? '-1'),
        // VAT value for the material; defaults to '0'.
        XmlHelpers.element('MatVAT', mat.matVAT?.toString() ?? '0'),
        // Default unit for the material; defaults to '1'.
        XmlHelpers.element('MatDefUnit', mat.matDefUnit?.toString() ?? '1'),
        // Material creation date in ISO8601 format; defaults to '1980-01-01T00:00:00'.
        XmlHelpers.element('MatCreateDate', mat.matCreateDate?.toIso8601String() ?? '1980-01-01T00:00:00'),
        // First cost date for the material in ISO8601 format; defaults to '1980-01-01T00:00:00'.
        XmlHelpers.element('MatFirstCostDate', mat.matFirstCostDate?.toIso8601String() ?? '1980-01-01T00:00:00'),
        // Previous quantity of the material; defaults to '0.00'.
        XmlHelpers.element('MatPrevQty', mat.matPrevQty ?? '0.00'),
      ],
    );
  }
}