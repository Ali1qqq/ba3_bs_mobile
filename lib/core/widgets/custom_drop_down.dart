import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown(
      {super.key,
      required this.value,
      required this.listValue,
      required this.label,
      required this.onChange,
      this.isFullBorder,
      this.size,
      this.enable = true});

  final double? size;
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 0.4.sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.headLineStyle3,
          ),
          VerticalSpace(),
          Container(
            color: Colors.white,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintStyle: AppTextStyles.headLineStyle3.copyWith(overflow: TextOverflow.ellipsis),
                hintText: label,
                // labelText: label,
                enabled: enable ?? true,
                labelStyle: AppTextStyles.headLineStyle3.copyWith(overflow: TextOverflow.ellipsis),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blueColor, width: 2),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blueColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blueColor, width: 4),
                ),
              ),
              value: value == '' ? null : value,
              iconEnabledColor: Colors.blue,
              hint: Text(label, style: AppTextStyles.headLineStyle4, overflow: TextOverflow.ellipsis),
              onChanged: onChange,
              items: listValue.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  final String value, label;

  final bool? isFullBorder;
  final List<String> listValue;

  final Function(String? value) onChange;
}