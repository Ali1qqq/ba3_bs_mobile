import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/materials/data/models/materials/material_group.dart';

/// A class responsible for exporting material groups into an XML structure.
class GroupsExport {
  /// Exports a list of MaterialGroupModel objects as an XML element.
  ///
  /// This method creates an XML element with the tag 'Groups'. It starts by adding a child
  /// element 'GroupsCount' which represents the total number of groups (formatted with two decimals).
  /// Then, it maps each material group to its corresponding XML element with the tag 'G',
  /// containing various properties of the group.
  ///
  /// Parameters:
  /// - [groups]: A list of MaterialGroupModel objects to be exported.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the exported material groups.
  xml.XmlElement exportGroups(List<MaterialGroupModel> groups) {
    final groupElements = <xml.XmlNode>[
      // Create an XML element to display the count of groups.
      xml.XmlElement(
        xml.XmlName('GroupsCount'),
        [],
        [xml.XmlText(groups.length.toStringAsFixed(2))],
      ),
      // Map each material group to its XML representation.
      ...groups.map((g) => xml.XmlElement(
            xml.XmlName('G'),
            [],
            [
              XmlHelpers.element('gPtr', g.matGroupGuid),
              XmlHelpers.element('GroupCode', g.groupCode),
              XmlHelpers.element('GroupName', g.groupName),
              XmlHelpers.element('GroupLatinName', g.groupLatinName),
              XmlHelpers.element('ParentGuid', g.parentGuid),
              XmlHelpers.element('GroupNotes', g.groupNotes),
              XmlHelpers.element('GroupSecurity', g.groupSecurity.toString()),
              XmlHelpers.element('GroupType', g.groupType.toString()),
              XmlHelpers.element('GroupVat', g.groupVat.toStringAsFixed(2)),
              XmlHelpers.element('GroupNumber', g.groupNumber.toString()),
              XmlHelpers.element('GroupBranchMask', g.groupBranchMask.toString()),
            ],
          )),
    ];

    // Return the root 'Groups' XML element containing all group elements.
    return xml.XmlElement(xml.XmlName('Groups'), [], groupElements);
  }
}