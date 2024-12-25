import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldWithoutIcon extends StatefulWidget {
  const CustomTextFieldWithoutIcon({
    super.key,
    required this.textEditingController,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.onIconPressed,
    this.onChanged,
    this.inputFormatters,
    this.isNumeric = false,
    this.enabled = true,
    this.maxLine = 1,
    this.height,
    this.suffixIcon,
    this.textStyle,
  });

  final TextEditingController textEditingController;
  final void Function(String)? onSubmitted;
  final Function()? onIconPressed;
  final void Function(String _)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool isNumeric, enabled;
  final FormFieldValidator<String>? validator;
  final double? height;
  final Widget? suffixIcon;
  final TextStyle? textStyle;
  final int? maxLine;

  @override
  State<CustomTextFieldWithoutIcon> createState() => _CustomTextFieldWithoutIconState();
}

class _CustomTextFieldWithoutIconState extends State<CustomTextFieldWithoutIcon> {
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
      height: widget.height,
      child: TextFormField(
        maxLines: widget.maxLine,
        onChanged: widget.onChanged,
        validator: widget.validator,
        enabled: widget.enabled,
        onFieldSubmitted: widget.onSubmitted,
        controller: widget.textEditingController,
        keyboardType: widget.keyboardType,
        scrollPadding: EdgeInsets.zero,
        cursorHeight: 15,
        onTap: () => widget.textEditingController.selection =
            TextSelection(baseOffset: 0, extentOffset: widget.textEditingController.text.length),
        inputFormatters: widget.inputFormatters,
        style: widget.textStyle ?? const TextStyle(fontSize: 14),
        decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            isDense: true,
            border: UnderlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.black, // Change the border color
                width: 2.0, // Change the border width
              ),
              borderRadius: BorderRadius.circular(5.0), // Adjust border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.blue, // Change the border color when focused
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            suffixIcon: widget.suffixIcon,
            contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 4)),
        textAlign: TextAlign.center,
        // Center the text horizontally
      ),
    );
  }
}
