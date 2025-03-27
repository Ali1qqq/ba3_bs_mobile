/*
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/services/export_xml/accounts_export.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart' as xml;
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';

import '../../../../../features/accounts/data/models/account_model.dart';
import '../../../../../features/bond/data/models/bond_model.dart';
import '../../../../../features/cheques/data/models/cheques_model.dart';
import '../../../../../features/cheques/service/cheques_export.dart';
import '../../../../../features/customer/data/models/customer_model.dart';
import '../../../../../features/materials/data/models/materials/material_group.dart';
import '../../../../../features/materials/data/models/materials/material_model.dart';
import '../../../../../features/sellers/data/models/seller_model.dart';
import '../../../export_xml/addresses_export.dart';
import '../../../export_xml/bills_export.dart';
import '../../../export_xml/bonds_export.dart';
import '../../../export_xml/cheques_export.dart';
import '../../../export_xml/costs_export.dart';
import '../../../export_xml/customers_export.dart';

class ExportXmlService {
















  String generateFullXml({
    required List<BillModel> bills,
    required List<BondModel> bonds,
    required List<MaterialModel> materials,
    required List<ChequesModel> cheques,
    required List<CustomerModel> customers,
    required List<AccountModel> accounts,
    required List<MaterialGroupModel> groups,
    required List<StoreAccount> allStore,
    required List<SellerModel> sellers,
  }) {
    final builder = xml.XmlBuilder();
    // builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('MainExp', nest: () {
      builder.element('Export', nest: () {
        _buildStaticSections(builder, materials);
        builder.element('Accounts', nest:AccountsExport.exportAccounts(accounts).children);
        builder.element('Customers', nest: CustomersExport.exportCustomers(customers).children);
        AddressesExport.buildAddresses(builder);
        builder.element('Groups', nest: exportGroups(groups).children);
        builder.element('Stores', nest: exportStores(allStore).children);
        builder.element('Cost1', nest: CostsExport.exportCosts(sellers).children);
        builder.element('Materials', nest: exportMaterials(materials).children);
        builder.element('Pay', nest:BondsExport. exportBonds(bonds).children);

        builder.element('BillGuids', nest: exportBillGuids(bills).children);
        builder.element('BillTotCount', nest: bills.length.toString());
        for (var billElement in BillsExport. exportBills(bills)) {
          builder.element(billElement.name.toString(), nest: billElement.children);
        }
        builder.element('Chk', nest: ChequesExport.exportChecks(cheques).children);
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }














  xml.XmlElement _element(String name, String? value) {
    return xml.XmlElement(xml.XmlName(name), [], value == null || value.isEmpty ? [] : [xml.XmlText(value)]);
  }
}
*/