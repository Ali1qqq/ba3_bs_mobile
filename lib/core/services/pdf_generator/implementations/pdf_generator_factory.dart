import 'package:ba3_bs_mobile/features/bill/services/bill/bill_pdf_generator.dart';
import 'package:ba3_bs_mobile/features/bond/service/bond/bond_pdf_generator.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs_mobile/features/cheques/service/cheques_comparison_pdf_generator.dart';
import 'package:ba3_bs_mobile/features/cheques/service/cheques_pdf_generator.dart';

import '../../../../features/bill/data/models/bill_model.dart';
import '../../../../features/bill/services/bill/bill_comparison_pdf_generator.dart';
import '../../../../features/bond/data/models/bond_model.dart';
import '../../../../features/bond/service/bond/bond_comparison_pdf_generator.dart';
import '../interfaces/i_pdf_generator.dart';

class PdfGeneratorFactory {
  static IPdfGenerator resolveGenerator<T>(T model) {
    if (model is List<BillModel>) {
      // Handles multiple strategies for ChequesModel
      return BillComparisonPdfGenerator();
    } else if (model is BillModel) {
      // Returns a single BillEntryBondCreator wrapped in a list
      return BillPdfGenerator();
    } else if (model is BondModel) {
      // Returns a single BondEntryBondCreator wrapped in a list
      return BondPdfGenerator();
    } else if (model is List<BondModel>) {
      // Returns a single BondEntryBondCreator wrapped in a list
      return BondComparisonPdfGenerator();
    } else if (model is ChequesModel) {
      // Returns a single BondEntryBondCreator wrapped in a list
      return ChequesPdfGenerator();
    } else if (model is List<ChequesModel>) {
      // Returns a single BondEntryBondCreator wrapped in a list
      return ChequesComparisonPdfGenerator();
    }
    throw UnimplementedError("No EntryBondCreator implementation for model of type ${model.runtimeType}");
  }
}
