import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/widgets/searchable_account_field.dart';
import 'package:ba3_bs_mobile/core/widgets/store_dropdown.dart';
import 'package:ba3_bs_mobile/features/bill/ui/widgets/bill_shared/form_field_row.dart';
import 'package:ba3_bs_mobile/features/patterns/ui/widgets/add_pattern/text_field_with_label.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../accounts/controllers/accounts_controller.dart';
import '../../../../accounts/data/models/account_model.dart';
import '../../../controllers/pattern_controller.dart';
import 'pattern_type_dropdown.dart';

class AddPatternForm extends StatelessWidget {
  const AddPatternForm({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: patternController.patternFormHandler.formKey,
      child: Wrap(
        spacing: 20,
        alignment: WrapAlignment.spaceBetween,
        // runSpacing: 10,
        children: [
          FormFieldRow(
            firstItem: TextFieldWithLabel(
              label: AppStrings.shortcuts.tr,
              textEditingController: patternController.patternFormHandler.shortNameController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الاختصار'),
            ),
            secondItem: TextFieldWithLabel(
              label: AppStrings.al.tr + AppStrings.name.tr,
              textEditingController: patternController.patternFormHandler.fullNameController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم'),
            ),
          ),
          FormFieldRow(
            firstItem: TextFieldWithLabel(
              label: AppStrings.latinShortCut.tr,
              textEditingController: patternController.patternFormHandler.latinShortNameController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'اختصار لاتيني'),
            ),
            secondItem: TextFieldWithLabel(
              label: AppStrings.latinName.tr,
              textEditingController: patternController.patternFormHandler.latinFullNameController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم لاتيني'),
            ),
          ),
          FormFieldRow(
            firstItem: PatternTypeDropdown(patternController: patternController),
            secondItem: SearchableAccountField(
              readOnly: (patternController.selectedBillPatternType?.hasMaterialAccount ?? false),
              label: AppStrings.materials.tr,
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.materialsController.text = (accountModel.accName!);
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.materials, value: accountModel);
                }
              },
              textEditingController: patternController.patternFormHandler.materialsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'المواد'),
            ),
          ),
          FormFieldRow(
              firstItem: SearchableAccountField(
                label: AppStrings.discounts.tr,
                readOnly: (patternController.selectedBillPatternType?.hasDiscountsAccount ?? false),
                onSubmitted: (text) async {
                  AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                    query: text,
                    context: context,
                  );
                  if (accountModel != null) {
                    patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.discounts, value: accountModel);

                    patternController.patternFormHandler.discountsController.text = (accountModel.accName!);
                  }
                },
                textEditingController: patternController.patternFormHandler.discountsController,
                validator: (value) => patternController.patternFormHandler.validator(value, 'الحسميات'),
              ),
              secondItem: SearchableAccountField(
                label: AppStrings.additions.tr,
                readOnly: (patternController.selectedBillPatternType?.hasAdditionsAccount ?? false),
                onSubmitted: (text) async {
                  AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                    query: text,
                    context: context,
                  );
                  if (accountModel != null) {
                    patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.additions, value: accountModel);

                    patternController.patternFormHandler.additionsController.text = (accountModel.accName!);
                  }
                },
                textEditingController: patternController.patternFormHandler.additionsController,
                validator: (value) => patternController.patternFormHandler.validator(value, 'الاضافات'),
              )),
          FormFieldRow(
            firstItem: SearchableAccountField(
              label: AppStrings.cashes.tr,
              readOnly: (patternController.selectedBillPatternType?.hasCashesAccount ?? false),
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.caches, value: accountModel);

                  patternController.patternFormHandler.cachesController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.cachesController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'النقديات'),
            ),
            secondItem: SearchableAccountField(
              label: AppStrings.gifts.tr,
              readOnly: (patternController.selectedBillPatternType?.hasGiftsAccount ?? false),
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.materials, value: accountModel);

                  patternController.patternFormHandler.giftsController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.giftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الهدايا'),
            ),
          ),
          FormFieldRow(
            firstItem: SearchableAccountField(
              readOnly: (patternController.selectedBillPatternType?.hasGiftsAccount ?? false),
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.exchangeForGifts, value: accountModel);

                  patternController.patternFormHandler.exchangeForGiftsController.text = (accountModel.accName!);
                }
              },
              label: '${AppStrings.exchange.tr} ${AppStrings.gifts.tr}',
              textEditingController: patternController.patternFormHandler.exchangeForGiftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'مقابل الهدايا'),
            ),
            secondItem: StoreDropdown(storeSelectionHandler: patternController.patternFormHandler),
          )
        ],
      ),
    );
  }
}