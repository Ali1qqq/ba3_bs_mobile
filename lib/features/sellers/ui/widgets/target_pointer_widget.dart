import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TargetPointerWidget extends StatefulWidget {
  final double value;
  final double maxValue;
  final double minValue;
  final double midValue;

  const TargetPointerWidget({super.key, required this.value, required this.maxValue, required this.minValue, required this.midValue});

  @override
  State<TargetPointerWidget> createState() => TargetPointerWidgetState();
}

class TargetPointerWidgetState extends State<TargetPointerWidget> {
  late Timer _timer;
  double _value = 0;
  double limit = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // SfRadialGauge يملأ كامل الشاشة

            _buildWidgetPointerExample(context)
            ,
            // قيمة المؤشر تظهر في المنتصف
            Container(
              height: 75,
              width: 200,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(33, 33, 33, 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _value.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void initState() {
    limit = widget.value;
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (mounted) {
      _timer = Timer.periodic(const Duration(microseconds: 500), (Timer timer) {
        _incrementPointerValue();
      });
    }
  }

  void _incrementPointerValue() {
    setState(() {
      if (_value >= limit) {
        _value = limit;
        _timer.cancel();
      } else {
        _value++;
      }
    });
  }

  void addValue(double value) {
    limit = value;
    _startTimer();
  }

  void removeValue(double value) {
    limit = value;
    _startReverceTimer();
  }

  void _startReverceTimer() {
    if (mounted) {
      _timer = Timer.periodic(const Duration(microseconds: 500), (Timer timer) {
        _decrementPointerValue();
      });
    }
  }

  void _decrementPointerValue() {
    setState(() {
      if (_value <= limit) {
        _value = limit;
        _timer.cancel();
      } else {
        _value--;
      }
    });
  }

  SfRadialGauge _buildWidgetPointerExample(BuildContext context) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
          interval: widget.maxValue/10,
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
              value: _value,
              knobStyle: const KnobStyle(knobRadius: 0),
            ),
          ],
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: 0,
              label:widget.minValue.toString() ,
              labelStyle: GaugeTextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              endValue: widget.minValue,
              startWidth: 40,
              endWidth: 40,
              color: const Color.fromRGBO(74, 177, 70, 1),
            ),
            GaugeRange(
              startValue: widget.minValue,
              endValue: widget.midValue,
              label:widget.midValue.toString() ,
              labelStyle: GaugeTextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              startWidth: 40,
              endWidth: 40,
              color: const Color.fromRGBO(251, 190, 32, 1),
            ),
            GaugeRange(
              startValue: widget.midValue,
              endValue: widget.maxValue,
              label:widget.maxValue.toString() ,
              labelStyle: GaugeTextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              startWidth: 40,
              endWidth: 40,
              color: const Color.fromRGBO(237, 34, 35, 1),
            )
          ],
        )
      ],
    );
  }
}