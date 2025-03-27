import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/accounts/data/models/account_model.dart';
import '../../../features/bill/data/models/bill_model.dart';
import '../../../features/bond/data/models/bond_model.dart';
import '../../../features/cheques/data/models/cheques_model.dart';
import '../../../features/customer/data/models/customer_model.dart';
import '../../../features/materials/data/models/materials/material_group.dart';
import '../../../features/materials/data/models/materials/material_model.dart';
import '../../../features/sellers/data/models/seller_model.dart';
import '../../helper/enums/enums.dart';
import 'bills_export.dart';
import 'bonds_export.dart';
import 'cheques_export.dart';
import 'accounts_export.dart';
import 'customers_export.dart';
import 'materials_export.dart';
import 'groups_export.dart';
import 'stores_export.dart';
import 'costs_export.dart';
import 'static_sections.dart';
import 'addresses_export.dart';

/// A service that generates a complete XML export combining various sections
/// such as bills, bonds, cheques, accounts, customers, materials, groups, stores, costs, and static sections.
class ExportXmlService {
  final _bills = BillsExport();
  final _bonds = BondsExport();
  final _cheques = ChequesExport();
  final _accounts = AccountsExport();
  final _customers = CustomersExport();
  final _materials = MaterialsExport();
  final _groups = GroupsExport();
  final _stores = StoresExport();
  final _costs = CostsExport();
  final _static = StaticSections();
  final _addresses = AddressesExport();

  /// Generates the full XML export as a pretty formatted string.
  ///
  /// This method combines various XML sections created by individual export classes.
  /// It accepts multiple required parameters including bills, bonds, materials, cheques,
  /// customers, accounts, groups, stores, and sellers, and then builds an XML document
  /// with a hierarchical structure.
  ///
  /// Parameters:
  /// - [bills]: A map where each key is a [BillTypeModel] and its value is a list of [BillModel] objects.
  /// - [bonds]: A map where each key is a [BondType] and its value is a list of [BondModel] objects.
  /// - [materials]: A list of [MaterialModel] objects.
  /// - [cheques]: A list of [ChequesModel] objects.
  /// - [customers]: A list of [CustomerModel] objects.
  /// - [accounts]: A list of [AccountModel] objects.
  /// - [groups]: A list of [MaterialGroupModel] objects.
  /// - [allStore]: A list of store accounts.
  /// - [sellers]: A list of [SellerModel] objects.
  ///
  /// Returns:
  /// - A [String] containing the complete XML document in a pretty formatted style.
  String generateFullXml({
    required Map<BillTypeModel, List<BillModel>> bills,
    required Map<BondType, List<BondModel>> bonds,
    required List<MaterialModel> materials,
    required List<ChequesModel> cheques,
    required List<CustomerModel> customers,
    required List<AccountModel> accounts,
    required List<MaterialGroupModel> groups,
    required List<StoreAccount> allStore,
    required List<SellerModel> sellers,
  }) {
    final builder = xml.XmlBuilder();

    // Build the main XML document structure
    builder.element('MainExp', nest: () {
      builder.element('Export', nest: () {
        // Build static sections (e.g., headers, metadata, etc.)
        _static.buildStaticSections(
          builder: builder,
          materials: materials,
          bonds: bonds,
          bills: bills,
          chequesList: cheques,
        );

        // Build the Accounts section using exported accounts XML elements
        builder.element('Accounts', nest: _accounts.exportAccounts(accounts).children);

        // Build the Customers section using exported customers XML elements
        builder.element('Customers', nest: _customers.exportCustomers(customers).children);

        // Build the Addresses section (populates the XML builder directly)
        _addresses.buildAddresses(builder);

        // Build the Groups section using exported groups XML elements
        builder.element('Groups', nest: _groups.exportGroups(groups).children);

        // Build the Stores section using exported stores XML elements
        builder.element('Stores', nest: _stores.exportStores(allStore).children);

        // Build the Costs section using exported costs XML elements
        builder.element('Cost1', nest: _costs.exportCosts(sellers).children);

        // Build the Materials section using exported materials XML elements
        builder.element('Materials', nest: _materials.exportMaterials(materials).children);

        // Build the Pay section (bonds) by flattening the list of bond models from the map values
        builder.element('Pay', nest: _bonds.exportBonds(bonds.values.expand((bonds) => bonds).toList()).children);

        // Build the BillGuids section using exported bill GUIDs
        builder.element('BillGuids', nest: _bills.exportBillGuids(bills.values.expand((bills) => bills).toList()).children);

        // Add a BillTotCount element representing the total number of bill types (map keys count)
        builder.element('BillTotCount', nest: bills.length.toString());

        // Build the individual Bill elements by iterating over the exported bills
        for (var bill in _bills.exportBills(bills.values.expand((bills) => bills).toList())) {
          builder.element('Bill', nest: bill.children);
        }

        // Build the Checks section using exported cheques XML elements
        builder.element('Checks', nest: _cheques.exportChecks(cheques).children);
      });
    });

    // Return the final XML document as a pretty formatted string.
    return builder.buildDocument().toXmlString(pretty: true);
  }
}