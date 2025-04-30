import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

abstract class IBillController extends GetxController {
  // void updateCustomerAccount(AccountModel? newAccount);

  Future<void> sendToEmail(
      {required String recipientEmail,
      required BuildContext context,
      String? url,
      String? subject,
      String? body,
      List<String>? attachments});

  set updateIsBillSaved(bool newValue);
}