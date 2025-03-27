import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/pluto/controllers/pluto_controller.dart';

class PlutoGridWithAppBar<T> extends StatelessWidget {
  const PlutoGridWithAppBar({
    super.key,
    required this.onLoaded,
    required this.onSelected,
    this.onRowDoubleTap,
    this.title,
    this.isLoading = false,
    required this.tableSourceModels,
    this.icon,
    this.onIconPressed,
    this.leadingIcon,
    this.onLeadingIconPressed,
    this.type,
    this.bottomChild,
    this.appBar,
    this.onRowSecondaryTap,
    this.rowHeight,
    this.rightChild,
  });

  final Function(PlutoGridOnLoadedEvent) onLoaded;
  final Function(PlutoGridOnRowDoubleTapEvent)? onRowDoubleTap;
  final Function(PlutoGridOnSelectedEvent) onSelected;

  final String? title;
  final List<PlutoAdaptable> tableSourceModels;
  final bool isLoading;
  final IconData? icon;
  final VoidCallback? onIconPressed;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingIconPressed;
  final T? type;
  final Widget? bottomChild;
  final Widget? rightChild;
  final double? rowHeight;
  final AppBar? appBar;
  final Function(PlutoGridOnRowSecondaryTapEvent)? onRowSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? _buildAppBar(),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : _buildGrid(context),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GetBuilder<PlutoController>(
      builder: (controller) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: PlutoGrid(
                      key: controller.plutoKey,
                      onLoaded: (event) {
                        event.stateManager.activateColumnsAutoSize();

                        event.stateManager.setShowColumnFilter(true);

                        onLoaded(event);
                      },
                      onRowSecondaryTap: onRowSecondaryTap,
                      onSelected: onSelected,
                      onRowDoubleTap: onRowDoubleTap,
                      columns: controller.generateColumns<T>(tableSourceModels, type),
                      rows: controller.generateRows<T>(tableSourceModels, type),
                      mode: PlutoGridMode.selectWithOneTap,
                      configuration: PlutoGridConfiguration(
                        style: PlutoGridStyleConfig(
                            gridBackgroundColor: Colors.white.withAlpha(126),
                            rowHeight: rowHeight ?? 30,
                            evenRowColor: Colors.blue.shade200,
                            borderColor: Colors.blue,
                            gridBorderRadius: BorderRadius.all(Radius.circular(10)),
                            gridBorderColor: AppColors.backGroundColor,
                            // gridBorderRadius: BorderRadius.circular(50),

                            // cellTextStyle: TextStyle(fontFamily: 'Almarai'),
                            // columnTextStyle: TextStyle(fontFamily: 'Almarai'),
                            activatedBorderColor: Colors.teal),
                        localeText: Get.locale == Locale('ar', 'AR') ? PlutoGridLocaleText.arabic() : PlutoGridLocaleText(),
                      ),
                      createFooter: (stateManager) {
                        stateManager.setPageSize(100, notify: false);
                        return Container(
                          color: Colors.white, // حدد اللون المطلوب هنا
                          child: PlutoPagination(stateManager),
                        );
                      },
                    ),
                  ),
                  if (rightChild != null) rightChild!
                ],
              ),
            ),
            if (bottomChild != null) bottomChild!,
          ],
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      leading: leadingIcon != null
          ? IconButton(
              onPressed: onLeadingIconPressed,
              icon: Icon(leadingIcon),
            )
          : null,
      title: Text(title ?? AppStrings.dataTable.tr),
      actions: [
        if (icon != null)
          IconButton(
            onPressed: onIconPressed,
            color: Colors.blue,
            icon: Icon(icon),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Text('${AppStrings.numberOfAffectedItems.tr}: ${tableSourceModels.length}'),
        ),
      ],
    );
  }
}