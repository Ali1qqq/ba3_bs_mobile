import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../interfaces/i_mailer_messaging_service.dart';

class GmailMessagingService implements IMailerMessagingService {
  final String _username = 'ba3rak.ae@gmail.com';
  final String _password = 'ggicttcumjanxath';

  SmtpServer get _smtpServer => gmail(_username, _password);

  @override
  Future<void> sendMail(String recipientEmail,
      {String? url,
      String? subject,
      String? body,
      List<String>? attachments}) async {
    final String newBody = body ??
        (url == null
            ? "<h1>شكرا لك لزيارتك محل برج العرب للهواتف المتحركة</h1>"
            : "<h1>شكرا لك لزيارتك محل برج العرب للهواتف المتحركة</h1>\n<p>لمراجعة الفاتورة يمكنك تتبع الرابط التالي \n "
                "$url</p>");

    final message = Message()
      ..from = Address(_username, 'برج العرب للهواتف المتحركة')
      ..recipients.add(recipientEmail)
      ..subject = subject ??
          'الموضوع:فاتورتك الألكترونية من برج العرب للهواتف المتحركة بتاريخ ${Timestamp.now().toDate()}'
      ..html = newBody;

    if (attachments != null) {
      for (String attachmentPath in attachments) {
        message.attachments.add(
          FileAttachment(File(attachmentPath))
            ..location = Location.inline
            ..fileName = getFileName(attachmentPath),
        );
      }
    }

    await send(message, _smtpServer);
  }

  String getFileName(String filePath) => filePath.split('/').last;
}
