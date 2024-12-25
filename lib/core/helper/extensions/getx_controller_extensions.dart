import 'package:get/get.dart';

T read<T>() => Get.find<T>();

extension GetXControllerExtensions on GetInterface {
  T putIfAbsent<T extends GetxController>(T controllerBuilder) {
    if (!Get.isRegistered<T>()) {
      Get.put(controllerBuilder);
    }
    return Get.find<T>();
  }

  T read<T extends GetxController>() => Get.find<T>();
}
