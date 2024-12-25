import 'package:flutter/material.dart';

class VerticalSpace extends StatelessWidget {
  const VerticalSpace([this.height = 10.0, Key? key]) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class HorizontalSpace extends StatelessWidget {
  const HorizontalSpace([this.width = 10.0, Key? key]) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}
