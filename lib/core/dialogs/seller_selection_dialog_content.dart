import 'package:ba3_bs_mobile/features/sellers/data/models/seller_model.dart';
import 'package:flutter/material.dart';

class SellerSelectionDialogContent extends StatelessWidget {
  final List<SellerModel> sellers;
  final Function(SellerModel selectedSeller) onSellerTap;

  const SellerSelectionDialogContent({super.key, required this.sellers, required this.onSellerTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sellers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Center(
            child: Text(
              sellers[index].costName!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          onTap: () {
            // Trigger the callback with the selected seller
            onSellerTap(sellers[index]);
          },
        );
      },
    );
  }
}