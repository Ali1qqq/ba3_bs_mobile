import 'package:get/get.dart';

import '../extensions/getx_controller_extensions.dart';

mixin ControllerInitializer {
  /// Safely retrieves a parameter from a map and checks its type.
  T requireParam<T>(Map<String, dynamic> params, {required String key}) {
    final value = params[key];
    if (value is T) return value;
    throw ArgumentError(
        'Expected parameter of type $T for key "$key", but got ${value.runtimeType}');
  }

  /// Ensures that a controller is initialized and returns the instance.
  T createController<T extends GetxController>(String tag,
          {required T controller}) =>
      put<T>(controller, tag: tag);
}
