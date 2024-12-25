import 'dart:async';
import 'dart:ui';

class Debounce {
  Timer? _timer;

  void call({
    required Duration duration,
    required VoidCallback action,
  }) {
    _timer?.cancel(); // Cancel the existing timer
    _timer = Timer(duration, action); // Start a new timer
  }

  void cancel() {
    _timer?.cancel(); // Cancel the timer
    _timer = null;
  }

  bool get isActive => _timer?.isActive ?? false;
}
