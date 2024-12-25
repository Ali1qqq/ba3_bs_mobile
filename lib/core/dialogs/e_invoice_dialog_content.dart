import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../features/floating_window/services/overlay_service.dart';
import '../i_controllers/i_bill_controller.dart';

class EInvoiceDialogContent extends StatelessWidget {
  const EInvoiceDialogContent({
    super.key,
    required this.billController,
    required this.billId,
  });

  final IBillController billController;
  final String billId;

  @override
  Widget build(BuildContext context) {
    final url = 'https://ba3-bs.firebaseapp.com/?id=$billId&year=${DateTime.now().year}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: url,
          version: QrVersions.auto,
          size: MediaQuery.of(context).size.height * 0.25,
        ),
        const SizedBox(height: 20),
        const Text(
          "مشاركة عبر",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text("البريد الألكتروني:"),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter email",
                ),
                onSubmitted: (recipientEmail) {
                  billController.sendToEmail(
                    recipientEmail: recipientEmail,
                    url: url,
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
              },
              icon: const Icon(Icons.copy, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        const ElevatedButton(
          onPressed: OverlayService.back,
          child: Text("Close"),
        ),
      ],
    );
  }
}
