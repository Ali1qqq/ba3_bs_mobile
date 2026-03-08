import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/controller/loan_request_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddLoanDialog extends StatelessWidget {
  const AddLoanDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanController>();

    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'طلب سلفة جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // حقل المبلغ
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "المبلغ",
                hintText: "أدخل المبلغ المطلوب",
                prefixIcon: const Icon(Icons.attach_money, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // حقل السبب
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "السبب",
                hintText: "أدخل سبب طلب السلفة",
                prefixIcon: const Icon(Icons.description, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  if (controller.addLoanState.value == RequestState.loading) {
                    return const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  return ElevatedButton(
                    onPressed: () {
                      if (amountController.text.isEmpty ||
                          reasonController.text.isEmpty) {
                        Get.snackbar(
                          'خطأ',
                          'الرجاء ملء جميع الحقول',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          colorText: Colors.red,
                        );
                        return;
                      }

                      controller.amount.value =
                          double.tryParse(amountController.text) ?? 0;
                      controller.reason.value = reasonController.text;
                      controller.addLoan();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('إرسال الطلب'),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
