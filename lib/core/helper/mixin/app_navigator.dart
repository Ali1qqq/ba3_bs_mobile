import 'package:get/get.dart';

mixin AppNavigator {
  void to(String route, {dynamic arguments}) {
    Get.toNamed(route, arguments: arguments);
  }

  void offAll(String route, {dynamic arguments}) {
    Get.offAllNamed(route, arguments: arguments);
  }

  void replace(String route, {dynamic arguments}) {
    Get.offNamed(route, arguments: arguments);
  }

  void goBack() {
    Get.back();
  }

  String? get currentRoute => Get.currentRoute;

  bool isRoute(String route) => Get.currentRoute == route;
}
