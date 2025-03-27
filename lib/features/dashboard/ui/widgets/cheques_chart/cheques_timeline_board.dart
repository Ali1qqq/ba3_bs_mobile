import 'package:ba3_bs_mobile/features/dashboard/ui/widgets/cheques_chart/cheques_chart_summary_section.dart';
import 'package:ba3_bs_mobile/features/dashboard/ui/widgets/cheques_chart/cheques_timeline_chart.dart';
import 'package:flutter/material.dart';

import '../../../controller/cheques_timeline_controller.dart';
import 'cheques_timeline_header.dart';

class ChequesTimelineBoard extends StatelessWidget {
  final ChequesTimelineController chequesTimelineController;

  const ChequesTimelineBoard({
    super.key,
    required this.chequesTimelineController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChequesTimelineHeader(controller: chequesTimelineController),
        ChequesBarChart(chequesTimelineController: chequesTimelineController),
        ChequesChartSummarySection(controller: chequesTimelineController),
      ],
    );
  }
}