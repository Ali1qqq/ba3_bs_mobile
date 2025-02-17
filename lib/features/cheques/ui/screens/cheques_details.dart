import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_search_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs_mobile/features/cheques/ui/widgets/cheques_details/cheques_details_app_bar.dart';
import 'package:ba3_bs_mobile/features/cheques/ui/widgets/cheques_details/cheques_details_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_spacer.dart';
import '../widgets/cheques_details/cheques_details_body_form.dart';
import '../widgets/cheques_details/cheques_details_buttons.dart';

class ChequesDetailsScreen extends StatelessWidget {
  final String tag;
  final ChequesType chequesTypeModel;
  final ChequesDetailsController chequesDetailsController;
  final ChequesSearchController chequesSearchController;

  const ChequesDetailsScreen(
      {super.key,
      required this.tag,
      required this.chequesTypeModel,
      required this.chequesDetailsController,
      required this.chequesSearchController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChequesSearchController>(
        tag: tag,
        builder: (_) {
          final ChequesModel currentCheques = chequesSearchController.getCurrentCheques;

          return GetBuilder<ChequesDetailsController>(
              tag: tag,
              builder: (_) {
                return Scaffold(
                  appBar: ChequesDetailsAppBar(
                      chequesDetailsController: chequesDetailsController,
                      chequesSearchController: chequesSearchController,
                      chequesTypeModel: chequesTypeModel),
                  body: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                          child: Column(
                        children: [
                          ChequesDetailsHeader(
                            chequesDetailsController: chequesDetailsController,
                          ),
                          const VerticalSpace(20),
                          AddChequeForm(
                            chequesDetailsController: chequesDetailsController,
                          ),
                          const VerticalSpace(),
                        ],
                      )),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Divider(),
                                const VerticalSpace(),
                                AddChequeButtons(
                                  chequesDetailsController: chequesDetailsController,
                                  chequesSearchController: chequesSearchController,
                                  chequesType: chequesTypeModel,
                                  chequesModel: currentCheques,
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                );
              });
        });
  }
}