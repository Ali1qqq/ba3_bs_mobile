import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/features/patterns/ui/widgets/add_pattern/text_field_with_label.dart';
import 'package:flutter/material.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../../core/widgets/store_dropdown.dart';
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
        runSpacing: 10,
        children: [
          TextFieldWithLabel(
            label: 'الاختصار',
            textEditingController: patternController.patternFormHandler.shortNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاختصار'),
          ),
          TextFieldWithLabel(
            label: 'الاسم',
            textEditingController: patternController.patternFormHandler.fullNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم'),
          ),
          TextFieldWithLabel(
            label: 'اختصار لاتيني',
            textEditingController: patternController.patternFormHandler.latinShortNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'اختصار لاتيني'),
          ),
          TextFieldWithLabel(
            label: 'الاسم لاتيني',
            textEditingController: patternController.patternFormHandler.latinFullNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم لاتيني'),
          ),
          PatternTypeDropdown(patternController: patternController),
          if (patternController.selectedBillPatternType?.hasMaterialAccount ?? false)
            SearchableAccountField(
              label: 'المواد',
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.materialsController.text = (accountModel.accName!);
                  patternController.patternFormHandler.setSelectedAccounts = {BillAccounts.materials: accountModel};
                }
              },
              textEditingController: patternController.patternFormHandler.materialsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'المواد'),
            ),
          if (patternController.selectedBillPatternType?.hasDiscountsAccount ?? false)
            SearchableAccountField(
              label: 'الحسميات',
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.setSelectedAccounts = {BillAccounts.discounts: accountModel};

                  patternController.patternFormHandler.discountsController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.discountsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الحسميات'),
            ),
          if (patternController.selectedBillPatternType?.hasAdditionsAccount ?? false)
            SearchableAccountField(
              label: 'الاضافات',
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.setSelectedAccounts = {BillAccounts.additions: accountModel};

                  patternController.patternFormHandler.additionsController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.additionsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الاضافات'),
            ),
          if (patternController.selectedBillPatternType?.hasCashesAccount ?? false)
            SearchableAccountField(
              label: 'النقديات',
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.setSelectedAccounts = {BillAccounts.caches: accountModel};

                  patternController.patternFormHandler.cachesController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.cachesController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'النقديات'),
            ),
          if (patternController.selectedBillPatternType?.hasGiftsAccount ?? false)
            SearchableAccountField(
              label: 'الهدايا',
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.setSelectedAccounts = {BillAccounts.gifts: accountModel};

                  patternController.patternFormHandler.giftsController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.giftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الهدايا'),
            ),
          if (patternController.selectedBillPatternType?.hasGiftsAccount ?? false)
            SearchableAccountField(
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.setSelectedAccounts = {BillAccounts.exchangeForGifts: accountModel};

                  patternController.patternFormHandler.exchangeForGiftsController.text = (accountModel.accName!);
                }
              },
              label: 'مقابل الهدايا',
              textEditingController: patternController.patternFormHandler.exchangeForGiftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'مقابل الهدايا'),
            ),
          StoreDropdown(storeSelectionHandler: patternController.patternFormHandler),
        ],
      ),
    );
  }
}
