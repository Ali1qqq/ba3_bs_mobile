import 'package:ba3_bs_mobile/core/widgets/searchable_account_field.dart';
import 'package:ba3_bs_mobile/core/widgets/store_dropdown.dart';
import 'package:ba3_bs_mobile/features/patterns/ui/widgets/add_pattern/text_field_with_label.dart';
import 'package:flutter/material.dart';

import '../../../controllers/pattern_controller.dart';
import 'pattern_type_dropdown.dart';

class AddPatternForm extends StatelessWidget {
  const AddPatternForm({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: patternController.formKey,
      child: Wrap(
        spacing: 20,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 10,
        children: [
          TextFieldWithLabel(
            label: 'الاختصار',
            textEditingController: patternController.shortNameController,
            validator: (value) => patternController.validator(value, 'الاختصار'),
          ),
          TextFieldWithLabel(
            label: 'الاسم',
            textEditingController: patternController.fullNameController,
            validator: (value) => patternController.validator(value, 'الاسم'),
          ),
          TextFieldWithLabel(
            label: 'اختصار لاتيني',
            textEditingController: patternController.latinShortNameController,
            validator: (value) => patternController.validator(value, 'اختصار لاتيني'),
          ),
          TextFieldWithLabel(
            label: 'الاسم لاتيني',
            textEditingController: patternController.latinFullNameController,
            validator: (value) => patternController.validator(value, 'الاسم لاتيني'),
          ),
          PatternTypeDropdown(patternController: patternController),
          SearchableAccountField(
            label: 'المواد',
            textEditingController: patternController.materialsController,
            validator: (value) => patternController.validator(value, 'المواد'),
          ),
          SearchableAccountField(
            label: 'الحسميات',
            textEditingController: patternController.discountsController,
            validator: (value) => patternController.validator(value, 'الحسميات'),
          ),
          SearchableAccountField(
            label: 'الاضافات',
            textEditingController: patternController.additionsController,
            validator: (value) => patternController.validator(value, 'الاضافات'),
          ),
          SearchableAccountField(
            label: 'النقديات',
            textEditingController: patternController.cachesController,
            validator: (value) => patternController.validator(value, 'النقديات'),
          ),
          SearchableAccountField(
            label: 'الهدايا',
            textEditingController: patternController.giftsController,
            validator: (value) => patternController.validator(value, 'الهدايا'),
          ),
          SearchableAccountField(
            label: 'مقابل الهدايا',
            textEditingController: patternController.exchangeForGiftsController,
            validator: (value) => patternController.validator(value, 'مقابل الهدايا'),
          ),
          StoreDropdown(storeSelectionHandler: patternController),
        ],
      ),
    );
  }
}
