import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../network/error/error_handler.dart';
import '../../../network/error/failure.dart';
import '../interfaces/i_mailer_messaging_service.dart';

class MailerMessagingRepository {
  final IMailerMessagingService _mailerService;

  MailerMessagingRepository(this._mailerService);

  Future<Either<Failure, Unit>> sendMail(String recipientEmail,
      {String? url, String? subject, String? body, List<String>? attachments}) async {
    try {
      await _mailerService.sendMail(recipientEmail, url: url, subject: subject, body: body, attachments: attachments);
      return const Right(unit);
    } catch (e) {
      log('[$e] فشل في ارسال الايميل');
      return Left(ErrorHandler(e).failure);
    }
  }
}
