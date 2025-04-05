import 'package:ba3_bs_mobile/core/dialogs/custom_alert_dialog/widgets/custom_alert_buttons.dart';
import 'package:flutter/material.dart';

import '../utils/custom_alert_gifs.dart';
import '../models/custom_alert_options.dart';
import '../models/custom_alert_type.dart';

class CustomAlertContainer extends StatelessWidget {
  final CustomAlertOptions options;

  const CustomAlertContainer({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final header = buildHeader(context);
    final title = buildTitle(context);
    final text = buildText(context);
    final buttons = buildButtons();
    final widget = buildWidget(context);

    final content = Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(
            height: 5.0,
          ),
          text,
          widget!,
          const SizedBox(
            height: 10.0,
          ),
          buttons
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: options.backgroundColor,
        borderRadius: BorderRadius.circular(options.borderRadius!),
      ),
      clipBehavior: Clip.antiAlias,
      width: options.width ?? MediaQuery.of(context).size.shortestSide,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [header, content],
      ),
    );
  }

  Widget buildHeader(context) {
    String? anim = CustomAlertGifs.success;
    switch (options.type) {
      case CustomAlertType.success:
        anim = CustomAlertGifs.success;
        break;
      case CustomAlertType.error:
        anim = CustomAlertGifs.error;
        break;
      case CustomAlertType.warning:
        anim = CustomAlertGifs.warning;
        break;
      case CustomAlertType.confirm:
        anim = CustomAlertGifs.confirm;
        break;
      case CustomAlertType.info:
        anim = CustomAlertGifs.info;
        break;
      case CustomAlertType.loading:
        anim = CustomAlertGifs.loading;
        break;
      default:
        anim = CustomAlertGifs.info;
        break;
    }

    if (options.customAsset != null) {
      anim = options.customAsset;
    }
    return Container(
      width: double.infinity,
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: options.headerBackgroundColor,
      ),
      child: Image.asset(
        anim ?? '',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildTitle(context) {
    final title = options.title ?? whatTitle();
    return Visibility(
      visible: title != null,
      child: Text(
        '$title',
        textAlign: options.titleAlignment ?? TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: options.titleColor,
                ) ??
            TextStyle(
              color: options.titleColor,
            ),
      ),
    );
  }

  Widget buildText(context) {
    if (options.text == null && options.type != CustomAlertType.loading) {
      return Container();
    } else {
      String? text = '';
      if (options.type == CustomAlertType.loading) {
        text = options.text ?? 'Loading';
      } else {
        text = options.text;
      }
      return Text(
        text ?? '',
        textAlign: options.textAlignment ?? TextAlign.center,
        style: TextStyle(
          color: options.textColor,
        ),
      );
    }
  }

  Widget? buildWidget(context) {
    if (options.widget == null && options.type != CustomAlertType.custom) {
      return Container();
    } else {
      Widget widget = Container();
      if (options.type == CustomAlertType.custom) {
        widget = options.widget ?? widget;
      }
      return options.widget;
    }
  }

  Widget buildButtons() {
    return CustomAlertButtons(
      options: options,
    );
  }

  String? whatTitle() {
    switch (options.type) {
      case CustomAlertType.success:
        return 'Success';
      case CustomAlertType.error:
        return 'Error';
      case CustomAlertType.warning:
        return 'Warning';
      case CustomAlertType.confirm:
        return 'Are You Sure?';
      case CustomAlertType.info:
        return 'Info';
      case CustomAlertType.custom:
        return null;
      case CustomAlertType.loading:
        return null;
    }
  }
}