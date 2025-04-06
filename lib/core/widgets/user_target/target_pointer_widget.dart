import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'target_pointer_controller.dart';

class TargetPointerWidget extends StatefulWidget {
  final double value;
  final double maxValue;
  final double minValue;
  final double midValue;

  const TargetPointerWidget({
    super.key,
    required this.value,
    required this.maxValue,
    required this.minValue,
    required this.midValue,
  });

  @override
  State<TargetPointerWidget> createState() => _TargetPointerWidgetState();
}

class _TargetPointerWidgetState extends State<TargetPointerWidget> {
  late final TargetPointerController controller;
String key=UniqueKey().toString();
  @override
  void initState() {
    super.initState();
    controller = Get.put(TargetPointerController(), tag:key);
    controller.start(widget.value);
  }

  @override
  void dispose() {
    Get.delete<TargetPointerController>(tag: key, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Obx(() {
          final currentValue = controller.value.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              _buildGauge(currentValue),
              _buildValueDisplay(currentValue),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildGauge(double currentValue) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
          interval: widget.maxValue / 10,
          labelOffset: 0.12,
          tickOffset: 0.125,
          radiusFactor: 1.1,
          endAngle: 95,
          isInversed: true,
          minorTicksPerInterval: 0,
          labelsPosition: ElementsPosition.outside,
          offsetUnit: GaugeSizeUnit.factor,
          showAxisLine: false,
          showLastLabel: true,
          maximum: widget.maxValue,
          pointers: <GaugePointer>[
            NeedlePointer(
              needleEndWidth: 5,
              needleLength: 0.7,
              value: currentValue,
              knobStyle: const KnobStyle(knobRadius: 0),
            ),
          ],
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: 0,
              endValue: widget.minValue,
              label: widget.minValue.toString(),
              labelStyle: const GaugeTextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              startWidth: 40,
              endWidth: 40,
              color: const Color.fromRGBO(74, 177, 70, 1),
            ),
            GaugeRange(
              startValue: widget.minValue,
              endValue: widget.midValue,
              label: widget.midValue.toString(),
              labelStyle: const GaugeTextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              startWidth: 40,
              endWidth: 40,
              color: const Color.fromRGBO(251, 190, 32, 1),
            ),
            GaugeRange(
              startValue: widget.midValue,
              endValue: widget.maxValue,
              label: widget.maxValue.toString(),
              labelStyle: const GaugeTextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              startWidth: 40,
              endWidth: 40,
              color: const Color.fromRGBO(237, 34, 35, 1),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildValueDisplay(double value) {
    return Container(
      height: 75,
      width: 200,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(33, 33, 33, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}