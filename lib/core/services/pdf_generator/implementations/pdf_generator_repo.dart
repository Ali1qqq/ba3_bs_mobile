import '../interfaces/i_pdf_generator.dart';

class PdfGeneratorRepository<T> {
  final IPdfGenerator<T> _pdfGenerator;

  PdfGeneratorRepository({required IPdfGenerator<T> pdfGenerator})
      : _pdfGenerator = pdfGenerator;

  Future<String> savePdf(T itemModel, String fileName,
      {String? logoSrc, String? fontSrc}) async {
    return await _pdfGenerator.generatePdf(itemModel, fileName,
        logoSrc: logoSrc, fontSrc: fontSrc);
  }
}
