import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/controller/loan_request_controller.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/data/model/loan_request_model.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/ui/widgets/add_loan_dilaog.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/ui/widgets/loan_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoanRequestsPage extends GetView<LoanController> {
  const LoanRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.getLoansState.value == RequestState.loading ||
            controller.deleteLoanState.value == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.loans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_money,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "لا توجد طلبات سلف",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "اضغط على زر + لإضافة طلب جديد",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.loans.length,
          itemBuilder: (context, index) {
            final loan = controller.loans[index];

            // تحديد لون الحالة
            Color statusColor;
            IconData statusIcon;
            String statusText;

            switch (loan.status) {
              case LoanStatus.approved:
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                statusText = 'مقبولة';
                break;
              case LoanStatus.rejected:
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                statusText = 'مرفوضة';
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                statusText = 'قيد الانتظار';
            }

            return LoanCardWidget(
              statusColor: statusColor,
              statusIcon: statusIcon,
              statusText: statusText,
              loan: loan,
              controller: controller,
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLoanDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("طلب سلفة"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // نافذة إضافة طلب سلفة جديد
  void _showAddLoanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: const AddLoanDialog(),
        );
      },
    );
  }
}
