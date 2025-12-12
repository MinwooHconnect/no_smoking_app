import 'package:get/get.dart';
import '../bindings/home_binding.dart';
import '../views/home.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      binding: HomeBinding(),
    ),
  ];
}
