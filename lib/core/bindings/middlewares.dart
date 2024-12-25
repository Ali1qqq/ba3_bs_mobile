import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

class LandscapeMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,

    ]);


    return null;
  }
  @override
  void onPageDispose() {
    // إعادة الوضع الرأسي عند مغادرة الصفحة
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.onPageDispose();
  }
}