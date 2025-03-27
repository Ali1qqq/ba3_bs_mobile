import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

class CustomTextFieldWithIcon extends StatefulWidget {
  const CustomTextFieldWithIcon({
    super.key,
    required this.textEditingController,
    required this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.onIconPressed,
    this.onChanged,
    this.inputFormatters,
    this.isNumeric = false,
    this.textStyle,
     this.readOnly=false,
  });

  final TextEditingController textEditingController;
  final void Function(String) onSubmitted;
  final FormFieldValidator<String>? validator;
  final Function()? onIconPressed;
  final void Function(String _)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool isNumeric;

  final TextStyle? textStyle;

  final bool readOnly;

  @override
  State<CustomTextFieldWithIcon> createState() => _CustomTextFieldWithIconState();
}

class _CustomTextFieldWithIconState extends State<CustomTextFieldWithIcon> {
  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(convertArabicNumbersToEnglish);
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(convertArabicNumbersToEnglish);
    super.dispose();
  }

  void convertArabicNumbersToEnglish() {
    if (widget.isNumeric) {
      final text = widget.textEditingController.text;
      final convertedText = text.replaceAllMapped(
        RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 0x660).toString(),
      );

      if (text != convertedText) {
        widget.textEditingController.value = widget.textEditingController.value.copyWith(
          text: convertedText,
          selection: TextSelection.collapsed(offset: convertedText.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:AppConstants.constHeightTextField,

      child: TextFormField(
        readOnly: widget.readOnly,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        onChanged: widget.onChanged,
        cursorHeight: 15,
        scrollPadding: EdgeInsets.zero,
        controller: widget.textEditingController,
        inputFormatters: widget.inputFormatters,
        onTap: () => widget.textEditingController.selection =
            TextSelection(baseOffset: 0, extentOffset: widget.textEditingController.text.length),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
            fillColor:  Colors.white,
            filled: true,
            isDense: true,
            suffixIconConstraints: BoxConstraints(maxHeight: AppConstants.constHeightTextField, maxWidth: 45,minWidth: 45),
            suffixIcon: Icon(
                Icons.search
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.blue, // Change the border color when focused
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            // suffixIcon: SizedBox.shrink(),
            contentPadding: const EdgeInsets.fromLTRB(0, 12,0, 12)),
        textAlign: TextAlign.center,


      // Center the text horizontally
      ),
    );
  }
}