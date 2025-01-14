import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';
import '../../../data/models/role_model.dart';

class AddRoleScreen extends StatelessWidget {
  const AddRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text(controller.roleModel?.roleName ?? 'دور جديد'),
          actions: [
            AppButton(
              title: controller.roleModel?.roleId == null ? 'إضافة' : 'تعديل',
              onPressed: () {
                controller.saveOrUpdateRole(existingRoleModel: controller.roleModel);
              },
              iconData: controller.roleModel?.roleId == null ? Icons.add : Icons.edit,
            ),
            const HorizontalSpace(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: ListView(
            children: [
              const Text('الاسم', style: TextStyle(fontSize: 16)),
              Form(
                key: controller.roleFormHandler.formKey,
                child: Container(
                  color: Colors.grey.shade200,
                  child: TextFormField(
                    controller: controller.roleFormHandler.roleNameController,
                    validator: (value) => controller.roleFormHandler.defaultValidator(value, 'أسم الصلاحية'),
                  ),
                ),
              ),
              const VerticalSpace(20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تحديد الكل',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(controller.areAllRolesSelected() ? Icons.clear_all : Icons.select_all),
                      onPressed: () {
                        // Toggle select/deselect all roles
                        if (controller.areAllRolesSelected()) {
                          controller.deselectAllRoles();
                        } else {
                          controller.selectAllRoles();
                        }
                      },
                    ),
                  ],
                ),
              ),
              for (final roleType in RoleItemType.values)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            roleType.value,
                            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(
                              controller.areAllRolesSelectedForType(roleType) ? Icons.clear_all_outlined : Icons.select_all_outlined,
                            ),
                            onPressed: () {
                              // Toggle select/deselect all roles under this RoleItemType
                              if (controller.areAllRolesSelectedForType(roleType)) {
                                controller.deselectAllRolesForType(roleType);
                              } else {
                                controller.selectAllRolesForType(roleType);
                              }
                            },
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            for (final roleItem in RoleItem.values) checkBoxWidget(roleType, roleItem, controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget checkBoxWidget(RoleItemType key, RoleItem roleItem, UserManagementController controller) {
    return Row(
      children: [
        StatefulBuilder(builder: (context, setState) {
          return Checkbox(
            fillColor: WidgetStatePropertyAll(Colors.blue.shade800),
            checkColor: Colors.white,
            overlayColor: const WidgetStatePropertyAll(Colors.white),
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: Colors.white),
            ),
            value: (controller.roleFormHandler.rolesMap[key]?.contains(roleItem) ?? false),
            onChanged: (newValue) {
              if (newValue!) {
                if (controller.roleFormHandler.rolesMap[key] == null) {
                  controller.roleFormHandler.rolesMap[key] = [roleItem];
                } else {
                  controller.roleFormHandler.rolesMap[key]?.add(roleItem);
                }
              } else {
                controller.roleFormHandler.rolesMap[key]?.remove(roleItem);
              }

              setState(() {});
            },
          );
        }),
        Text(
          roleItem.value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
