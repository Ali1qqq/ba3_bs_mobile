// lib/controllers/target_pointer_controller.dart

import 'dart:async';
import 'package:get/get.dart';

class TargetPointerController extends GetxController {
  final RxDouble value = 0.0.obs;
  double _limit = 0;
  Timer? _timer;

  void start(double initialValue) {
    _limit = initialValue;
    value.value = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(microseconds: 500), (_) => _increment());
  }

  void _increment() {
    if (value.value >= _limit) {
      value.value = _limit;
      _timer?.cancel();
    } else {
      value.value++;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}