import 'package:get/get.dart';

T read<T>({String? tag}) => Get.find<T>(tag: tag);

T put<T>(T controller, {String? tag, bool permanent = false}) => Get.put<T>(controller, tag: tag, permanent: permanent);

Future<T> putAsync<T>(Future<T> controller) => Get.putAsync<T>(() => controller);

void lazyPut<T>(T controller) => Get.lazyPut<T>(() => controller, fenix: true);

extension GetXControllerExtensions on GetInterface {
  T putIfAbsent<T extends GetxController>(T controllerBuilder) {
    if (!Get.isRegistered<T>()) {
      Get.put(controllerBuilder);
    }
    return Get.find<T>();
  }
}
