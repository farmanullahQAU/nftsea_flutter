import 'package:get/get.dart';
import 'package:nft_sea/bindings/binding.dart';
import 'package:nft_sea/home/view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: AppBinding(),
    ),
  ];
}
