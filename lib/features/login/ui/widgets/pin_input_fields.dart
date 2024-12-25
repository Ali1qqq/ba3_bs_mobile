// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
//
// import '../../../users_management/controllers/user_management_controller.dart';
//
// class PinInputFields extends StatelessWidget {
//   const PinInputFields({super.key, required this.controller});
//
//   final UserManagementController controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Pinput(
//         length: 6,
//         onCompleted: (pinCode) {
//           log(pinCode);
//           controller.userPassword = pinCode;
//           controller.checkUserStatus();
//         },
//         defaultPinTheme: PinTheme(
//           width: 56,
//           height: 56,
//           textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
//           decoration: BoxDecoration(
//             color: const Color.fromRGBO(200, 238, 253, 1),
//             border: Border.all(color: const Color.fromRGBO(140, 140, 140, 1)),
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ));
//   }
// }
