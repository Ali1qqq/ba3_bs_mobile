import 'package:get/get.dart';

T read<T>({String? tag}) => Get.find<T>(tag: tag);

T put<T>(T controller, {String? tag, bool permanent = false}) =>
    Get.put<T>(controller, tag: tag, permanent: permanent);

Future<T> putAsync<T>(Future<T> controller) =>
    Get.putAsync<T>(() => controller);

void lazyPut<T>(T controller, {String? tag, bool fenix = true}) =>
    Get.lazyPut<T>(() => controller, tag: tag, fenix: fenix);

void delete<T>({String? tag, bool force = false}) =>
    Get.delete<T>(tag: tag, force: force);

bool isRegistered<T>({String? tag}) => Get.isRegistered<T>(tag: tag);

T putIfAbsent<T extends GetxController>(T controllerBuilder,
    {String? tag, bool permanent = false}) {
  if (!isRegistered<T>()) {
    put(controllerBuilder, tag: tag, permanent: permanent);
  }
  return read<T>();
}

T lazyPutIfAbsent<T extends GetxController>(T controllerBuilder,
    {String? tag, bool fenix = true}) {
  if (!isRegistered<T>()) {
    lazyPut(controllerBuilder, tag: tag, fenix: fenix);
  }
  return read<T>();
}
