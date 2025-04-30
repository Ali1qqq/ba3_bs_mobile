abstract class IMailerMessagingService {
  Future<void> sendMail(String recipientEmail,
      {String? url, String? subject, String? body, List<String>? attachments});
}
