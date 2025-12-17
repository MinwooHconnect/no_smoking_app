import 'package:get/get.dart';
import '../bindings/home_binding.dart';
import '../views/home.dart';
import '../views/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      binding: HomeBinding(),
    ),
  ];
}
