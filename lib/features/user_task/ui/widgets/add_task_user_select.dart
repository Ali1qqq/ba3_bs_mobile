import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../controller/all_task_controller.dart';

class AddTaskUserSelect extends StatelessWidget {

  final  AllTaskController controller;
  const AddTaskUserSelect({
    super.key,
    required  this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 450,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          alignment: Alignment.center,
          child: ListView.separated(
            separatorBuilder: (context, index) => VerticalSpace(),
            itemCount: controller.userList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(controller.userList[index].userName!, style: TextStyle(fontSize: 16)),
                subtitle: Text("${AppStrings.identificationNumber.tr}: ${controller.userList[index].userId}",
                    style: TextStyle(color: Colors.grey)),
                trailing: Checkbox(
                  value: controller.checkUserStatus(controller.userList[index].userId!),
                  onChanged: (bool? value) {
                    controller.updatedSelectedUsers(controller.userList[index].userId!, value!);
                  },
                ),
              );
            },
          ),
        ),
        VerticalSpace(5),
        Row(
          children: [
            Text('تم تحديد ${controller.taskFormHandler.selectedUsers.length} من المستخدمين'),
            Spacer(),
            Row(
              children: [
                Text(controller.taskFormHandler.selectedUsers.isEmpty ? 'تحديد الكل' : 'الغاء الكل'),
                HorizontalSpace(10),
                IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.loose(Size(30, 30)),
                    onPressed: () {
                      controller.selectOrDeselectAllUsers();
                    },
                    icon: Icon(
                      controller.taskFormHandler.selectedUsers.isEmpty
                          ? Icons.check_box_outline_blank_rounded
                          : Icons.check_box_rounded,
                      size: 18,
                    )),
              ],
            ),
            HorizontalSpace(10)
          ],
        )
      ],
    );
  }
}