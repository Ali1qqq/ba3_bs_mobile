import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';

import '../constants/app_assets.dart';
import '../constants/app_strings.dart';
import '../services/mailer_messaging/implementations/gmail_messaging_service.dart';
import '../services/mailer_messaging/implementations/mailer_messaging_repo.dart';
import '../services/pdf_generator/implementations/pdf_generator_repo.dart';
import '../services/pdf_generator/interfaces/i_pdf_generator.dart';
import '../utils/app_ui_utils.dart';

mixin PdfBase {
  /// Sends the bill email with optional attachments
  Future<void> sendToEmail({
    required String recipientEmail,
    String? url,
    String? subject,
    String? body,
    List<String>? attachments,
  }) async {
    final mailerRepo = MailerMessagingRepository(GmailMessagingService());

    final result = await mailerRepo.sendMail(
      recipientEmail,
      url: url,
      subject: subject,
      body: body,
      attachments: attachments,
    );

    result.fold(
          (failure) => _onEmailSendFailure(failure.message),
          (_) => _onEmailSendSuccess(attachments),
    );
  }

  /// Handles the failure scenario during email sending
  void _onEmailSendFailure(String errorMessage) => AppUIUtils.onFailure(errorMessage);

  /// Handles the success scenario during email sending
  void _onEmailSendSuccess(List<String>? attachments) {
    AppUIUtils.onSuccess('تم إرسال البريد الإلكتروني بنجاح');
    if (attachments != null) {
      log('Attachments sent: ${attachments.first}');
      _deleteAttachments(attachments); // Optionally delete after sending
    } else {
      Get.back();
    }
  }

  /// Deletes attachments after email is sent successfully
  Future<void> _deleteAttachments(List<String> attachments) async {
    for (final filePath in attachments) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        log('Deleted file: $filePath');
      }
    }
  }

  /// Generates a PDF and sends it via email
  Future<void> generateAndSendPdf<T>({
    required IPdfGenerator<T> pdfGenerator,
    required T itemModel,
    required String? itemModelId,
    required List items,
    required String fileName,
    String recipientEmail = AppStrings.recipientEmail,
    String logoSrc = AppAssets.ba3Logo,
    String fontSrc = AppAssets.notoSansArabicRegular,
    String? url,
    String? subject,
    String? body,
  }) async {
    if (!hasModelId(itemModelId)) return;

    if (!hasModelItems(items)) return;

    final pdfFilePath = await _generatePdf(
        pdfGenerator: pdfGenerator,
        itemModel: itemModel,
        fileName: fileName,
        logoSrc: logoSrc,
        fontSrc: fontSrc);

    await sendToEmail(
      recipientEmail: recipientEmail,
      url: url,
      subject: subject,
      body: body,
      attachments: [pdfFilePath],
    );
  }

  /// Generates the bill PDF and returns the file path
  Future<String> _generatePdf<T>({
    required IPdfGenerator<T> pdfGenerator,
    required T itemModel,
    required String fileName,
    String? logoSrc,
    String? fontSrc,
  }) async {
    final pdfGeneratorRepo = PdfGeneratorRepository<T>(pdfGenerator: pdfGenerator);

    return await pdfGeneratorRepo.savePdf(itemModel, fileName, logoSrc: logoSrc, fontSrc: fontSrc);
  }

  bool hasModelItems(List items) {
    if (items.isEmpty) {
      AppUIUtils.onFailure('يرجى إضافة عنصر واحد على الأقل إلى الفاتورة!');
      return false;
    }
    return true;
  }

  bool hasModelId(String? itemId) {
    if (itemId == null) {
      AppUIUtils.onFailure('يرجى إضافة الفاتورة أولا!');
      return false;
    }
    return true;
  }
}
