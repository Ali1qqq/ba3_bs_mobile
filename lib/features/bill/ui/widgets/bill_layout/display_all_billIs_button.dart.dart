import 'package:flutter/material.dart';

class DisplayAllBillsButton extends StatelessWidget {
  const DisplayAllBillsButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(30.0),
          child: const Center(
            child: Text(
              "عرض جميع الفواتير",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
          )),
    );
  }
}
