import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:xml/xml.dart';

import '../../../features/bond/data/models/bond_model.dart';
import '../../../features/cheques/data/models/cheques_model.dart';
import '../../../features/materials/data/models/materials/material_model.dart';
import '../../helper/enums/enums.dart';

/// This class is responsible for generating the static sections
/// of the exported XML file, such as version info, export settings,
/// bill types, pay types, currencies, and tax configuration.
class StaticSections {
  /// Builds all static XML sections that do not depend on dynamic transactional data.
  ///
  /// - [builder]: the XML builder used to construct the document.
  /// - [materials]: the list of materials to include in the tax section.
  /// - [bonds]: a map of bond types and their associated bond records.
  /// - [chequesList]: the list of cheques to include in the export.
  void buildStaticSections({
    required XmlBuilder builder,
    required List<MaterialModel> materials,
    required Map<BondType, List<BondModel>> bonds,
    required Map<BillTypeModel, List<BillModel>> bills,
    required List<ChequesModel> chequesList,
  }) {
    _buildExportVersion(builder);
    _buildExpSetting(builder, bonds, chequesList, bills);
    _buildExportType(builder);
    _buildBillsTypes(builder, bills);
    _buildChequesDescription(builder);
    _buildPayTypesDescription(builder, bonds);
    _buildCurrencySection(builder);
    _buildGccTaxOptions(builder);
    _buildMaterialTaxes(builder, materials);
  }

  /// Builds the ExportVersion section that identifies the version of the export file.
  void _buildExportVersion(XmlBuilder builder) {
    builder.element('ExportVersion', nest: () {
      builder.element('V', nest: '3.1');
      builder.element('Id', nest: '64a6a2dd-d2e8-43f0-ab6c-f4692312d711');
    });
  }

  /// Builds export settings, including counts, ranges of pay numbers and cheques, and export filters.
  void _buildExpSetting(
    XmlBuilder builder,
    Map<BondType, List<BondModel>> bonds,
    List<ChequesModel> chequesList,
    Map<BillTypeModel, List<BillModel>> bills,
  ) {
    builder.element('ExpSetting', nest: () {
      builder
        ..element('Counter', nest: '9')
        ..element('StdCount', nest: '0')
        ..element('OtherCnt', nest: '7');

      builder.element('Bills', nest: () {
        final billTypes = bills.keys.map((billType) {
          final typeGuideString = billType.billTypeId.toString();
          final billsForType = bills[billType];
          final lastBillNumber = billsForType?.lastOrNull?.billDetails.billNumber ?? '0';
          final firstBillNumber = billsForType?.firstOrNull?.billDetails.billNumber ?? '0';
          return [typeGuideString, '$lastBillNumber,$firstBillNumber'];
        }).toList();
        for (var bill in billTypes) {
          builder.element('Bill', nest: () {
            builder.element('Range', nest: '${bill[0]} ${bill[1]}');
          });
        }
      });

      builder.element('PayCnt', nest: '4');

      builder.element('Pays', nest: () {
        final pays = bonds.keys.map((bondType) {
          final lastNumber = bonds[bondType]?.lastOrNull?.payNumber ?? '0';
          final firstNumber = bonds[bondType]?.lastOrNull?.payNumber ?? '0';
          return [bondType, '$lastNumber,$firstNumber'];
        }).toList();
        for (var pay in pays) {
          builder.element('Pay', nest: () {
            builder.element('Range', nest: '${pay[0]} ${pay[1]}');
          });
        }
      });

      builder.element('ChkCnt', nest: '3');
      builder.element('Notes', nest: () {
        final chequeType = [
          ['fc3fe7b6-dbb4-4007-b8a4-fc3533dccd18', '${chequesList.lastOrNull?.chequesNumber ?? '0'},1'],
          ['c27c5972-2b40-47df-8e3e-6ee29c4d5838', '1,1'],
        ];
        for (var note in chequeType) {
          builder.element('Note', nest: () {
            builder.element('Range', nest: '${note[0]} ${note[1]}');
          });
        }
      });

      final defaultFields = {
        'Ignore': '0',
        'CrdtAsCash': '0',
        'ExportType': '1',
        'ExportMat': '0',
        'ExportAllMats': '0',
        'MatFrom': null,
        'MatTo': null,
        'ExportStore': '0',
        'ExportAllStores': '0',
        'StoreFrom': null,
        'StoreTo': null,
        'ExportGroup': '0',
        'ExportAllGroup': '0',
        'GroupFrom': null,
        'GroupTo': null,
        'ExportAcc': '0',
        'ExportAllAcc': '0',
        'AccpFrom': null,
        'AccTo': null,
        'ExportCost': '0',
        'ExportAllCosts': '0',
        'CostFrom': null,
        'CostTo': null,
        'StoreGuid': '00000000-0000-0000-0000-000000000000',
        'ExpEntry': '1',
        'ExpBll': '1',
        'ExpPay': '1',
        'ExpChk': '1',
        'ExpMBonus': '0',
        'ExpMatAcc': '0',
        'ExpCashBill': '0',
        'IsExpBillDate': '0',
        'ExpStartBillDate': '1-1-2022',
        'ExpBillDate': '10-11-2022',
        'FilterStoreGuid': '00000000-0000-0000-0000-000000000000',
        'EntryFrom': '0',
        'EntryTo': '10000',
      };

      defaultFields.forEach((key, value) {
        builder.element(key, nest: value);
      });
    });
  }

  /// Builds the ExportType section, indicating the export type value.
  void _buildExportType(XmlBuilder builder) {
    builder.element('ExportType', nest: () {
      builder.element('T', nest: '1');
    });
  }

  /// Builds a list of bill types, including names, IDs, and ranges.
  void _buildBillsTypes(XmlBuilder builder, Map<BillTypeModel, List<BillModel>> bills) {
    final billTypes = bills.entries.where((e) => e.value.isNotEmpty).map((entry) {
      final billType = entry.key;
      final billList = entry.value;
      final from = billList.firstOrNull?.billDetails.billNumber?.toString() ?? '0';
      final to = billList.lastOrNull?.billDetails.billNumber?.toString() ?? '0';
      return [
        billType.id,
        billType.fullName,
        billType.latinFullName,
        '1',
        from,
        to,
      ];
    }).toList();

    builder.element('BillsTypes', nest: () {
      for (final t in billTypes) {
        builder.element('D', nest: () {
          builder.element('Type', nest: t[0]);
          builder.element('Name', nest: t[1]);
          builder.element('LatinName', nest: t[2]);
          builder.element('iType', nest: t[3]);
          builder.element('From', nest: t[4]);
          builder.element('To', nest: t[5]);
        });
      }
    });
  }

  /// Builds cheque type definitions with their IDs, names, and ranges.
  void _buildChequesDescription(XmlBuilder builder) {
    final cheques = [
      ['fc3fe7b6-dbb4-4007-b8a4-fc3533dccd18', 'شيكات مدفوعة', 'شيكات مدفوعة', '1', '99'],
      ['c27c5972-2b40-47df-8e3e-6ee29c4d5838', 'شيكات تأمين', 'شيكات تأمين', '1', '1'],
    ];

    builder.element('ChkDesc', nest: () {
      for (var c in cheques) {
        builder.element('K', nest: () {
          builder.element('Type', nest: c[0]);
          builder.element('Name', nest: c[1]);
          builder.element('LatinName', nest: c[2]);
          builder.element('DefPayAccGuid', nest: '00000000-0000-0000-0000-000000000000');
          builder.element('DefRecAccGuid', nest: '00000000-0000-0000-0000-000000000000');
          builder.element('From', nest: c[3]);
          builder.element('To', nest: c[4]);
        });
      }
    });
  }

  /// Builds payment type definitions and their ranges dynamically from bond data.
  void _buildPayTypesDescription(XmlBuilder builder, Map<BondType, List<BondModel>> bonds) {
    builder.element('PayDesc', nest: () {
      for (final entry in bonds.entries) {
        final type = entry.key;
        final bondList = entry.value;

        // تخطي إذا لا يوجد أي سندات
        if (bondList.isEmpty) continue;

        final firstNumber = bondList.firstOrNull?.payNumber?.toString() ?? '0';
        final lastNumber = bondList.lastOrNull?.payNumber?.toString() ?? '0';

        builder.element('Y', nest: () {
          builder.element('Type', nest: type.typeGuide);
          builder.element('Name', nest: type.label);
          builder.element('LatinName', nest: type.value);
          builder.element('From', nest: firstNumber);
          builder.element('To', nest: lastNumber);
          builder.element('TaxType', nest: type.taxType.toString()); // تأكد أنك تملك taxType
        });
      }
    });
  }

  /// Builds currency metadata section, currently only includes UAE Dirham.
  void _buildCurrencySection(XmlBuilder builder) {
    builder.element('Currency', nest: () {
      builder.element('CurrencyCount', nest: '1');
      builder.element('cr', nest: () {
        builder.element('CurGuid', nest: '884EDCDE-C172-490D-A2F2-F10A0B90326A');
        builder.element('CurCode', nest: 'د.هـ.');
        builder.element('CurName', nest: 'درهم إماراتي');
        builder.element('CurVal', nest: '1');
        builder.element('CurPartName', nest: 'فلس');
        builder.element('CurPartPrecision', nest: '100');
        builder.element('CurSecurity', nest: '0');
        builder.element('CurDate', nest: '1-1-1980');
        builder.element('CurLatinName', nest: 'UAE Dirham');
        builder.element('CurLatinPartName', nest: 'Fils');
        builder.element('CurNumber', nest: '4.94065645841246544176568792868e-324');
        builder.element('CurBranchMask', nest: '0');
      });
    });
  }

  /// Builds settings related to the GCC tax system (flags and country code).
  void _buildGccTaxOptions(XmlBuilder builder) {
    builder.element('GCCTaxSystemOption', nest: () {
      builder.element('GCCTaxSystemOptionFlag', nest: '1');
    });

    builder.element('GCCTaxSystemCountry', nest: () {
      builder.element('xmlGCCTaxSystemCountryNumber', nest: '0');
    });
  }

  /// Builds a list of tax entries per material, including whether it's taxable and tax rate.
  void _buildMaterialTaxes(XmlBuilder builder, List<MaterialModel> materials) {
    builder.element('GCCMaterialTaxes', nest: () {
      for (var mat in materials) {
        final isTaxable = mat.matVatGuid == 'xtc33mNeCZYR98i96pd8';
        final generatedId = XmlHelpers.uuid.v4();

        builder.element('GCCMaterialTax', nest: () {
          builder.element('GCCMaterialTaxGUID', nest: generatedId);
          builder.element('GCCMaterialTaxType', nest: '1.00');
          builder.element('GCCMaterialTaxCode', nest: isTaxable ? '1.00' : '4.00');
          builder.element('GCCMaterialTaxRatio', nest: isTaxable ? '5.00' : '0.0');
          builder.element('GCCMaterialTaxMatGUID', nest: mat.id);
          builder.element('GCCMaterialTaxProfitMargin', nest: 'F');
        });
      }
    });
  }
}