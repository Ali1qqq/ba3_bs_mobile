import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../../features/bill/data/models/bill_model.dart';
import '../../../features/migration/controllers/migration_controller.dart';
import '../../constants/app_constants.dart';
import '../../helper/extensions/getx_controller_extensions.dart';
import '../../network/api_constants.dart';
import '../../utils/app_ui_utils.dart';
import '../firebase/implementations/services/remote_config_service.dart';

//ba3business@gmail.com
//Ba3Alarab220011
//+971568666411
class WhatsappService {
  // Step 1: Private named constructor
  WhatsappService._internal();

  // Step 2: Static instance
  static final WhatsappService instance = WhatsappService._internal();

  // ✅ Your existing methods below
  Future<void> sendBillToWhatsApp({
    required BillModel itemModel,
    required String recipientPhoneNumber,
  }) async {
    final invoiceUrl = generateInvoiceUrl(
      documentId: itemModel.billId!,
      type: itemModel.billTypeModel.billTypeLabel!,
    );

    await sendWhatsAppInvoiceLink(
      clientPhoneNumber: recipientPhoneNumber,
      invoiceUrl: invoiceUrl,
    );
  }

  String get dataBaseYear {
    final currentVersion = read<MigrationController>().currentVersion;
    return currentVersion == AppConstants.defaultVersion || currentVersion.isEmpty ? '' : currentVersion;
  }

  String generateInvoiceUrl({
    required String documentId,
    required String type,
  }) {
    final baseUrl = 'https://ba3-bs.web.app';
    final params = {
      'id': documentId,
      'type': type,
      if (dataBaseYear != '') 'year': dataBaseYear,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    return uri.toString();
  }

  Future<void> sendWhatsAppInvoiceLink({
    required String clientPhoneNumber,
    required String invoiceUrl,
  }) async {
    final url = Uri.parse(
      'https://graph.facebook.com/v22.0/${ApiConstants.whatsappPhoneNumberID}/messages',
    );

    final headers = {
      'Authorization': 'Bearer ${RemoteConfigService.whatsappAccessToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode(
      {
        "messaging_product": "whatsapp",
        "to": clientPhoneNumber,
        "type": "template",
        "template": {
          "name": "elctronic_invoice",
          "language": {"code": "ar"},
          "components": [
            {
              "type": "body",
              "parameters": [
                {"type": "text", "text": invoiceUrl}
              ]
            }
          ]
        }
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      log('✅ تم إرسال رابط الفاتورة بنجاح!', name: 'SendWhatsAppInvoiceLink');
      AppUIUtils.onSuccess('✅ تم إرسال رابط الفاتورة بنجاح إلى الواتساب!');
    } else {
      log('⚠️ فشل في إرسال الرابط: ${response.body}', name: 'SendWhatsAppInvoiceLink');
    }
  }
}
