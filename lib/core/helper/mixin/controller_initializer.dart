import 'package:get/get.dart';

mixin ControllerInitializer {
  /// Safely retrieves a parameter from a map and checks its type.
  T requireParam<T>(Map<String, dynamic> params, String key) {
    final value = params[key];
    if (value is T) return value;
    throw ArgumentError('Expected parameter of type $T for key "$key", but got ${value.runtimeType}');
  }

  /// Ensures that a controller is initialized and returns the instance.
  T getOrCreateController<T extends GetxController>(
    String tag, {
    required T Function() controllerBuilder,
  }) {
    if (!Get.isRegistered<T>(tag: tag)) {
      Get.create<T>(controllerBuilder, permanent: false, tag: tag);
    }
    return Get.find<T>(tag: tag);
  }
}
