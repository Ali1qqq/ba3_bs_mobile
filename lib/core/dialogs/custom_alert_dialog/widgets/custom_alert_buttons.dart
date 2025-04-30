import 'package:flutter/material.dart';

import '../models/custom_alert_options.dart';
import '../models/custom_alert_type.dart';

class CustomAlertButtons extends StatelessWidget {
  final CustomAlertOptions options;

  const CustomAlertButtons({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          cancelBtn(context),
          const SizedBox(width: 10.0),
          options.type != CustomAlertType.loading
              ? okayBtn(context)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget okayBtn(context) {
    if (!options.showConfirmBtn!) {
      return const SizedBox();
    }
    final showCancelBtn =
        options.type == CustomAlertType.confirm ? true : options.showCancelBtn!;

    final okayBtn = buildButton(
        context: context,
        isOkayBtn: true,
        text: options.confirmBtnText!,
        onTap: () {
          options.timer?.cancel();
          options.onConfirmBtnTap != null
              ? options.onConfirmBtnTap!()
              : Navigator.pop(context);
        });

    if (showCancelBtn) {
      return Expanded(child: okayBtn);
    } else {
      return okayBtn;
    }
  }

  Widget cancelBtn(context) {
    final showCancelBtn =
        options.type == CustomAlertType.confirm ? true : options.showCancelBtn!;

    final cancelBtn = buildButton(
        context: context,
        isOkayBtn: false,
        text: options.cancelBtnText!,
        onTap: () {
          options.timer?.cancel();
          options.onCancelBtnTap != null
              ? options.onCancelBtnTap!()
              : Navigator.pop(context);
        });

    if (showCancelBtn) {
      return Expanded(child: cancelBtn);
    } else {
      return const SizedBox();
    }
  }

  Widget buildButton({
    BuildContext? context,
    required bool isOkayBtn,
    required String text,
    VoidCallback? onTap,
  }) {
    final btnText = Text(
      text,
      style: defaultTextStyle(isOkayBtn),
    );

    final okayBtn = MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: options.confirmBtnColor ?? Theme.of(context!).primaryColor,
      onPressed: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(7.5),
          child: btnText,
        ),
      ),
    );

    final cancelBtn = MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: options.cancelBtnColor ?? Theme.of(context!).cardColor,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(7.5),
        child: Center(
          child: btnText,
        ),
      ),
    );

    return isOkayBtn ? okayBtn : cancelBtn;
  }

  TextStyle defaultTextStyle(bool isOkayBtn) {
    final textStyle = TextStyle(
      color: isOkayBtn ? Colors.white : Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 18.0,
    );

    if (isOkayBtn) {
      return options.confirmBtnTextStyle ?? textStyle;
    } else {
      return options.cancelBtnTextStyle ?? textStyle;
    }
  }
}
