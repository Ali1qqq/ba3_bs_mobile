
import 'package:ba3_bs_mobile/features/patterns/ui/widgets/add_pattern/text_field_with_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../../core/widgets/store_dropdown.dart';
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
          SearchableAccountField(
            label: 'المواد',
            width: 1.sw,
            textEditingController: patternController.patternFormHandler.materialsController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'المواد'),
          ),
          SearchableAccountField(
            label: 'الحسميات',
            width: 1.sw,
            textEditingController: patternController.patternFormHandler.discountsController,
            //  validator: (value) => patternController.patternFormHandler.validator(value, 'الحسميات'),
          ),
          SearchableAccountField(
            label: 'الاضافات',
            width: 1.sw,
            textEditingController: patternController.patternFormHandler.additionsController,
            //   validator: (value) => patternController.patternFormHandler.validator(value, 'الاضافات'),
          ),
          SearchableAccountField(
            label: 'النقديات',
            width: 1.sw,
            textEditingController: patternController.patternFormHandler.cachesController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'النقديات'),
          ),
          SearchableAccountField(
            label: 'الهدايا',
            width: 1.sw,
            textEditingController: patternController.patternFormHandler.giftsController,
            //  validator: (value) => patternController.patternFormHandler.validator(value, 'الهدايا'),
          ),
          SearchableAccountField(
            label: 'مقابل الهدايا',
            width: 1.sw,
            textEditingController: patternController.patternFormHandler.exchangeForGiftsController,
            //    validator: (value) => patternController.patternFormHandler.validator(value, 'مقابل الهدايا'),
          ),
          StoreDropdown(storeSelectionHandler: patternController.patternFormHandler),
        ],
      ),
    );
  }
}
