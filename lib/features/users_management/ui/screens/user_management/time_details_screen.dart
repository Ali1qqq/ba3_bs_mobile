import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/user_management_controller.dart';

class TimeDetailsScreen extends StatefulWidget {
  final String oldKey;
  final String name;

  const TimeDetailsScreen({super.key, required this.oldKey, required this.name});

  @override
  State<TimeDetailsScreen> createState() => _TimeDetailsScreenState();
}

class _TimeDetailsScreenState extends State<TimeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: GetBuilder<UserManagementController>(
          builder: (controller) {
            // UserModel userModel = controller.allUserList[widget.oldKey]!;
            return const SizedBox();
            // return ListView.builder(
            //   itemCount: userModel.userTimeRecord!.length,
            //   itemBuilder: (context, index) {
            //     UserTimeRecord model =  userModel.userTimeRecord![index];
            //   return Text(model.date.toString() +"  "+ model.time.toString());
            // },);
          },
        ),
      ),
    );
  }
}
